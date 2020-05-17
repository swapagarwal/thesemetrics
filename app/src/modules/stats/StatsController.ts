import { ProjectService } from '@/modules/project';
import { StatsService } from '@/modules/stats/StatsService';
import { Controller, Get, Param, Res } from '@nestjs/common';
import { FastifyReply } from 'fastify';

@Controller()
export class StatsController {
  constructor(private readonly stats: StatsService, private readonly projects: ProjectService) {}

  @Get('/stats/:domain/:path')
  async getStats(
    @Param('domain') domain: string,
    @Param('path') path: string = '*',
    @Res() response: FastifyReply<Response>
  ) {
    if (path !== '*') path = '/' + path;
    const project = await this.projects.findProjectByDomain(domain);
    const devices = await this.stats.getDevices(project);
    const pageviews = await this.stats.getPageViews(project, path);

    response.header('Cache-Control', `public, max-age=${secondsRemainingToday()}, immutable`);

    return response.send({
      domain: project.domain,
      resource: path,
      devices,
      pageviews,
    });
  }
}

function secondsRemainingToday() {
  const now = new Date();
  const eod = new Date();

  eod.setUTCHours(23, 59, 59, 999);

  return (eod.getTime() - now.getTime()) / 1000;
}
