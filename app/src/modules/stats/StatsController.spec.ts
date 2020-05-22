import { StatsController } from '@/modules/stats/StatsController';
import { StatsService } from '@/modules/stats/StatsService';
import { ProjectService } from '@/modules/project';
import { FastifyReply } from 'fastify';
import { ReferrerKind } from '@thesemetrics/database';

describe('StatsController', () => {
  let controller: StatsController;
  let statsService: StatsService;
  let projectService: ProjectService;

  beforeAll(() => {
    statsService = {
      getDevices: () => [],
      getPageViews: () => [],
      getTopResources: () => [],
      getReferrers: () => [],
    } as any;
    projectService = {
      findProjectByDomain: (domain: string) => ({ domain }),
    } as any;
    controller = new StatsController(statsService, projectService);
  });

  describe('getStats', () => {
    let response: FastifyReply<Response>;

    beforeAll(() => {
      response = {
        header: () => response,
        type: () => response,
        send: () => response,
      } as any;
    });

    it('should collect stats for last 30 days ', async () => {
      const getDevices = jest.spyOn(statsService, 'getDevices');
      const getPageViews = jest.spyOn(statsService, 'getPageViews');
      const getTopResources = jest.spyOn(statsService, 'getTopResources');
      const getReferrers = jest.spyOn(statsService, 'getReferrers');
      const header = jest.spyOn(response, 'header');
      const send = jest.spyOn(response, 'send');

      const domain = 'example.com';
      await controller.getStats(response, domain);

      expect(getDevices).toHaveBeenCalledWith(expect.objectContaining({ domain }));
      expect(getPageViews).toHaveBeenCalledWith(expect.objectContaining({ domain }), '*');
      expect(getTopResources).toHaveBeenCalledWith(expect.objectContaining({ domain }));
      expect(getReferrers).toHaveBeenCalledWith(expect.objectContaining({ domain }), ReferrerKind.REFERRER);
      expect(header).toHaveBeenCalledWith('Cache-Control', 'public, max-age=3600, immutable');
      expect(send).toHaveBeenCalledWith(
        expect.objectContaining({ domain, resource: '*', devices: [], pageviews: [], resources: [], referrers: [] })
      );
    });
  });
});
