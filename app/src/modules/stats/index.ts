import { Module } from '@nestjs/common';
import DatabaseModule from '@/modules/db';
import ProjectModule from '@/modules/project';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DailyAggregateDevice, DailyAggregatePageView, DailyAggregateReferrerPageView } from '@thesemetrics/database';
import { StatsController } from '@/modules/stats/StatsController';
import { StatsService } from '@/modules/stats/StatsService';

@Module({
  imports: [
    DatabaseModule,
    ProjectModule,
    TypeOrmModule.forFeature([DailyAggregateDevice, DailyAggregatePageView, DailyAggregateReferrerPageView]),
  ],
  providers: [StatsController, StatsService],
  controllers: [StatsController],
})
export default class StatsModule {}
