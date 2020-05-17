import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import {
  User,
  Team,
  Project,
  PageView,
  DailyAggregateDevice,
  DailyAggregatePageView,
  DailyAggregateReferrerPageView,
  ProjectEvent,
} from '@thesemetrics/database';
import { APP_FILTER } from '@nestjs/core';
import { DatabaseExceptionFilter } from '@/modules/db/DatabaseExceptionFilter';

export * from '@thesemetrics/database';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.POSTGRES_URL,
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
      synchronize: false,
    }),
  ],
  providers: [{ provide: APP_FILTER, useClass: DatabaseExceptionFilter }],
})
export default class DatabaseModule {}
