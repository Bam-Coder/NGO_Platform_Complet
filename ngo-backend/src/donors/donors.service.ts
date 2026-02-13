import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Donor } from './donor.entity';
import { Project } from '../projects/project.entity';
import { ProjectsService } from '../projects/projects.service';

@Injectable()
export class DonorsService {
  constructor(
    @InjectRepository(Donor)
    private donorRepo: Repository<Donor>,
    private projectsService: ProjectsService,
  ) {}

  async create(data: Partial<Donor>) {
    const donor = this.donorRepo.create(data);

    if (data.projects && data.projects.length > 0) {
      // Verify that each project exists
      const projects = await Promise.all(
        data.projects.map(async (p: Project) => {
          const project = await this.projectsService.findOne(p.id);
          if (!project)
            throw new NotFoundException(`Project with id ${p.id} not found`);
          return project;
        })
      );

      donor.projects = projects;
    }

    return this.donorRepo.save(donor);
  }

  findAll() {
    return this.donorRepo.find({ relations: ['projects'] });
  }

  async findOne(id: number) {
    const donor = await this.donorRepo.findOne({
      where: { id },
      relations: ['projects'],
    });
    if (!donor) throw new NotFoundException('Donor not found');
    return donor;
  }
}
