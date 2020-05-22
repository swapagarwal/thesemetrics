import { QuerySerializer, SqlQuery, SQL_QUERIES, TestDatabaseModule } from '@/modules/db/test-helpers';
import { StatsService } from '@/modules/stats/StatsService';
import { Test } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';
import {
  DailyAggregateDevice,
  DailyAggregatePageView,
  DailyAggregateReferrerPageView,
  Project,
  ReferrerKind,
} from '@thesemetrics/database';

describe('StatsService', () => {
  let service: StatsService;
  let queries: SqlQuery[];
  const since = new Date('2020-05-20T00:00:00.000Z');
  const fakeProject: Project = { id: 1 } as any;

  expect.addSnapshotSerializer(QuerySerializer);

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [
        TestDatabaseModule.forRoot(),
        TypeOrmModule.forFeature([DailyAggregateDevice, DailyAggregatePageView, DailyAggregateReferrerPageView]),
      ],
      providers: [StatsService],
    }).compile();

    service = moduleRef.get(StatsService);
    queries = moduleRef.get(SQL_QUERIES);
  });

  beforeEach(() => {
    queries.length = 0;
  });

  describe('getDevices', () => {
    it('should query aggregated devices for the project', async () => {
      await expect(service.getDevices(fakeProject, since)).rejects.toThrow();
      expect(queries).toMatchSnapshot();
    });
  });

  describe('getPageViews', () => {
    it('should query aggregated pageviews for the project', async () => {
      await expect(service.getPageViews(fakeProject, '*', since)).rejects.toThrow();
      expect(queries).toMatchSnapshot();
    });
  });

  describe('getReferrers', () => {
    it('should query aggregated referrers for the project', async () => {
      await expect(service.getReferrers(fakeProject, ReferrerKind.REFERRER, '*', since)).rejects.toThrow();
      expect(queries).toMatchSnapshot();
    });
  });

  describe('getTopResources', () => {
    it('should query top resources for the project', async () => {
      await expect(service.getTopResources(fakeProject, since)).rejects.toThrow();
      expect(queries).toMatchSnapshot();
    });
  });
});
