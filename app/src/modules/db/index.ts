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
})
export default class DatabaseModule {}
