import { DailyAggregateDevice, DailyAggregatePageView, DailyAggregateReferrerPageView, Project } from '@/modules/db';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { MoreThanOrEqual, Repository } from 'typeorm';

@Injectable()
export class StatsService {
  constructor(
    @InjectRepository(DailyAggregateDevice)
    private readonly devices: Repository<DailyAggregateDevice>,
    @InjectRepository(DailyAggregatePageView)
    private readonly pageviews: Repository<DailyAggregatePageView>,
    @InjectRepository(DailyAggregateReferrerPageView)
    private readonly referrers: Repository<DailyAggregateReferrerPageView>
  ) {}

  async getPageViews(project: Project, resource = '*', since = getLastMonth()) {
    return this.pageviews.find({
      where: { project, date: MoreThanOrEqual(since), path: resource },
    });
  }

  async getReferrers(project: Project, resource = '*', since = getLastMonth()) {
    return this.referrers.find({
      where: { project, date: MoreThanOrEqual(since), path: resource },
    });
  }

  async getDevices(project: Project, since = getLastMonth()) {
    return this.devices.find({
      where: { project, date: MoreThanOrEqual(since) },
    });
  }
}

function getLastMonth() {
  const date = new Date();

  date.setDate(date.getDate() - 30);

  return date;
}
