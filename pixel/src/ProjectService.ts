import { Injectable } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import {
  Project,
  ProjectEvent,
  ProjectType,
  Team
} from '@thesemetrics/database'
import { Repository } from 'typeorm'

export interface ProjectEventPayload
  extends Omit<ProjectEvent, 'id' | 'createdAt' | 'project'> {
  domain: string
}

@Injectable()
export class ProjectService {
  constructor(
    @InjectRepository(Team)
    private readonly teams: Repository<Team>,
    @InjectRepository(Project)
    private readonly projects: Repository<Project>,
    @InjectRepository(ProjectEvent)
    private readonly events: Repository<ProjectEvent>
  ) {}

  public async isDomainAllowed(domain: string): Promise<boolean> {
    if (!(await this.projects.count({ where: { domain } }))) {
      const team = await this.teams.findOne(1)

      await this.projects.save({
        team,

        type: ProjectType.WEBSITE,
        name: domain,
        domain: domain,
      })
    }

    return true
  }

  public async mayBePushEvent(event: ProjectEventPayload): Promise<void> {
    if (!(await this.isDomainAllowed(event.domain))) return // -- ignore event.

    const project = await this.projects.findOneOrFail({
      where: { domain: event.domain },
    })

    console.log(event)

    await this.events.save({
      ...event,
      project,
    })
  }
}
