import { QuerySerializer, SqlQuery, TestDatabaseModule, SQL_QUERIES } from '@/modules/db/test-helpers';
import { ProjectService } from '@/modules/project/ProjectService';
import { Test } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Project } from '@thesemetrics/database';

describe('ProjectService', () => {
  let service: ProjectService;
  let queries: SqlQuery[];

  expect.addSnapshotSerializer(QuerySerializer);

  beforeEach(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [
        TestDatabaseModule.forRoot(),
        TypeOrmModule.forFeature([Project]),
      ],
      providers: [ProjectService],
    }).compile();

    service = moduleRef.get(ProjectService);
    queries = moduleRef.get(SQL_QUERIES)
  });

  describe('findProjectByDomain', () => {
    it('should query project by domain name', async () => {
      await expect(service.findProjectByDomain('example.com')).rejects.toThrow();
      expect(queries).toMatchSnapshot();
    });
  });
});
