import { Module } from '@nestjs/common';
import { ProjectService } from './ProjectService';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Project } from '@thesemetrics/database';
import DatabaseModule from '@/modules/db';

export { ProjectService } from './ProjectService';

@Module({
  imports: [DatabaseModule, TypeOrmModule.forFeature([Project])],
  providers: [ProjectService],
  exports: [ProjectService],
})
export default class ProjectModule {}
