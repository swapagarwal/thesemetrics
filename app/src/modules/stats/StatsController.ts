import { ReferrerKind } from '@/modules/db';
import { ProjectService } from '@/modules/project';
import { StatsService } from '@/modules/stats/StatsService';
import { Controller, Get, Query, Res } from '@nestjs/common';
import { FastifyReply } from 'fastify';

@Controller()
export class StatsController {
  constructor(private readonly stats: StatsService, private readonly projects: ProjectService) {}

  @Get('/stats')
  async getStats(
    @Query('domain') domain: string,
    @Query('path') path: string,
    @Res() response: FastifyReply<Response>
  ) {
    if (path !== '*') path = '/' + path;
    const project = await this.projects.findProjectByDomain(domain);
    const devices = await this.stats.getDevices(project);
    const pageviews = await this.stats.getPageViews(project, path);
    const resources = await this.stats.getTopResources(project);
    const referrers = await this.stats.getReferrers(project, ReferrerKind.REFERRER);

    if (!__DEV__) response.header('Cache-Control', `public, max-age=${secondsRemainingToday()}, immutable`);

    return response.type('application/json').send({
      domain: project.domain,
      resource: path,
      devices,
      pageviews,
      resources,
      referrers,
    });
  }
}

function secondsRemainingToday() {
  const now = new Date();
  const eod = new Date();

  eod.setUTCHours(23, 59, 59, 999);

  return (eod.getTime() - now.getTime()) / 1000;
}
