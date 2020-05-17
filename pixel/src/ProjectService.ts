import { Injectable, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Project, ProjectEvent, ProjectType, Team, PageView } from '@thesemetrics/database';
import { Repository } from 'typeorm';
import { lookup } from 'dns';

export interface PageViewOptions extends Omit<PageView, 'id' | 'createdAt' | 'createdOn' | 'project' | 'data'> {
  domain: string;
  data: Partial<{
    uuid: string;
    version: string;
    https: boolean;
    touch: boolean;
    javascript: boolean;
    browserVersion: string;
    osVersion: string;
    referrer: string;
  }>;
}

interface BaseEventOptions<Data = {}> {
  domain: string;
  path: string;
  session?: string;
  timestamp?: Date;
  data: Data & {
    uuid: string;
    version: string;
  };
}

export interface PageReadEventOptions extends BaseEventOptions<{ duration: number; completion: number }> {
  name: 'pageread';
}

export type EventOptions = PageReadEventOptions;

@Injectable()
export class ProjectService {
  constructor(
    @InjectRepository(Team) private readonly teams: Repository<Team>,
    @InjectRepository(Project) private readonly projects: Repository<Project>,
    @InjectRepository(PageView) private readonly pageviews: Repository<PageView>,
    @InjectRepository(ProjectEvent) private readonly events: Repository<ProjectEvent>
  ) {}

  public async isDomainAllowed(domain: string): Promise<boolean> {
    if (!(await this.projects.count({ where: { domain } }))) {
      // Check DNS entry exists.
      if (!__DEV__ && /^localhost(:[0-9]+)?$/.test(domain)) {
        return false;
      }

      if (!(await isDomainRegistered(domain))) {
        return false;
      }

      await this.projects.save({
        team: { id: 1 },
        type: ProjectType.WEBSITE,
        name: domain,
        domain: domain,
      });
    }

    return true;
  }

  private async findProject(domain: string) {
    if (!(await this.isDomainAllowed(domain))) {
      throw new ForbiddenException();
    }

    return this.projects.findOneOrFail({
      where: { domain },
    });
  }

  public async addPageView(event: PageViewOptions): Promise<void> {
    const project = await this.findProject(event.domain);

    if (event.referrer) {
      event.data.referrer = event.referrer.split('?')[0];
      event.referrer = event.data.referrer.replace(/^https?:\/\/((www|l|m)\.)?/i, '').replace(/\/+$/, '');

      if (/^google.([a-z]{2,3}|co\.[a-z]{2})(\/|$)/.test(event.referrer)) {
        event.referrer = 'google';
      } else if (/^facebook.([a-z]{2,3}|co\.[a-z]{2})(\/|$)/.test(event.referrer)) {
        event.referrer = 'facebook';
      } else if (/^twitter.([a-z]{2,3}|co\.[a-z]{2})(\/|$)/.test(event.referrer) || /^t.co\//.test(event.referrer)) {
        event.referrer = 'twitter';
      }
    }

    console.log(event)

    await this.pageviews.save({
      project,

      path: event.path,
      session: event.session,
      unique: event.unique,

      device: event.device,
      deviceType: event.deviceType,
      browser: event.browser,
      browserVersion: event.browserVersion,
      os: event.os,
      osVersion: event.osVersion,
      screenSize: event.screenSize,

      source: event.source,
      medium: event.medium,
      campaign: event.campaign,
      referrer: event.referrer,

      country: event.country,
      timezone: event.timezone,
      timestamp: event.timestamp,

      data: event.data as any,
    });
  }

  public async addEvent(event: EventOptions): Promise<void> {
    const project = await this.findProject(event.domain);
    
    await this.events.save({
      project,

      name: event.name,
      path: event.path,
      session: event.session,
      timestamp: event.timestamp,

      data: event.data as any,
    });
  }
}

async function isDomainRegistered(domain: string) {
  return new Promise((resolve) => lookup(domain, (error) => (error ? resolve(false) : resolve(true))));
}
