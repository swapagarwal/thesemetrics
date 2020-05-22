import { DynamicModule } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import {
  DailyAggregateDevice,
  DailyAggregatePageView,
  DailyAggregateReferrerPageView,
  PageView,
  Project,
  ProjectEvent,
  Team,
  User,
} from '@thesemetrics/database';
import FS from 'fs';
import Formatter from 'sql-formatter';

export interface SqlQuery {
  statement: string;
  parameters?: any[];
}

export interface SqlError extends SqlQuery {
  message: string;
}

export const SQL_ERRORS = '@test/sql-errors';
export const SQL_QUERIES = '@test/sql-queries';
export class TestDatabaseModule {
  static forRoot(): DynamicModule {
    const queries: SqlQuery[] = [];
    const errors: SqlError[] = [];

    return {
      module: TestDatabaseModule,
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqljs',
          logging: true,
          synchronize: false,
          logger: {
            log: () => {},
            logMigration: () => {},
            logQuerySlow: () => {},
            logSchemaBuild: () => {},
            logQueryError: (message, statement, parameters) => errors.push({ message, statement, parameters }),
            logQuery: (statement, parameters) => queries.push({ statement, parameters }),
          },
          entities: [
            User,
            Team,
            Project,
            PageView,
            DailyAggregateDevice,
            DailyAggregatePageView,
            DailyAggregateReferrerPageView,
            ProjectEvent,
          ],
        }),
      ],
      providers: [
        {
          provide: SQL_QUERIES,
          useValue: queries,
        },
        {
          provide: SQL_ERRORS,
          useValue: errors,
        },
      ],
    };
  }
}

function stringify(data: any) {
  switch (typeof data) {
    case 'undefined':
      return '';
    case 'string':
      return `'${data.replace(/'/g, "\\'")}'`;
    case 'object':
      if (data instanceof Date) {
        return `'${data.toISOString()}'`;
      }
    default:
      return JSON.stringify(data);
  }
}

export const QuerySerializer = {
  serialize(queries: SqlQuery[]) {
    let content = '\n';

    Array.from(queries).forEach((query, index) => {
      content += `-- Query ${index + 1}\n`;
      content += Formatter.format(query.statement + ';', {
        language: 'sql',
        params: query.parameters ? query.parameters.map(stringify) : undefined,
      });
      content += '\n\n';
    });

    return content;
  },
  test(value: any) {
    return (
      Array.isArray(value) &&
      value.every((query) => {
        if (typeof query === 'object') {
          if ('statement' in query) {
            return (
              typeof query.statement === 'string' &&
              (typeof query.statement === 'undefined' || Array.isArray(query.parameters))
            );
          }
        }
        return false;
      })
    );
  },
};
