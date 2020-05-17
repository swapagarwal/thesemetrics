import { InjectRepository } from '@nestjs/typeorm';
import { Project } from '@/modules/db';
import { Repository } from 'typeorm';

export class ProjectService {
  constructor(@InjectRepository(Project) private readonly projects: Repository<Project>) {}

  async findProjectByDomain(domain: string) {
    return this.projects.findOneOrFail({
      where: { domain },
    });
  }
}
