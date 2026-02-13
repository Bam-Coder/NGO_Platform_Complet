import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Project } from './project.entity';
import { User } from '../users/user.entity';
import { Donor } from '../donors/donor.entity';
import { CreateProjectDto } from './dto/create-project.dto';
import { Role as UserRole } from '../auth/roles.enum';
import { ProjectStatus } from './project-status.enum';

@Injectable()
export class ProjectsService {
  constructor(
    @InjectRepository(Project)
    private projectRepo: Repository<Project>,
    @InjectRepository(User)
    private userRepo: Repository<User>,
    @InjectRepository(Donor)
    private donorRepo: Repository<Donor>,
  ) {}

  async create(dto: CreateProjectDto) {
    const { managerId, donorIds, ...projectData } = dto;

    const manager = await this.userRepo.findOne({ where: { id: managerId } });
    if (!manager) {
      throw new NotFoundException(`Manager with id ${managerId} not found`);
    }

    let donors: Donor[] = [];
    if (donorIds && donorIds.length > 0) {
      donors = await this.donorRepo.findBy({ id: In(donorIds) });
    }

    const project = this.projectRepo.create({
      ...projectData,
      manager,
      donors,
    });

    return this.projectRepo.save(project);
  }

  findAll() {
    return this.projectRepo.find({
      relations: ['budgets', 'expenses', 'reports', 'donors', 'manager'],
    });
  }

  findAllForUser(user: { userId: number; role: UserRole }) {
    if (user.role === UserRole.ADMIN) {
      return this.findAll();
    }

    return this.projectRepo.find({
      where: { manager: { id: user.userId } },
      relations: ['budgets', 'expenses', 'reports', 'donors', 'manager'],
    });
  }

  async findOne(id: number) {
    const project = await this.projectRepo.findOne({
      where: { id },
      relations: ['budgets', 'expenses', 'reports', 'donors', 'manager'],
    });

    if (!project) {
      throw new NotFoundException(`Project with id ${id} not found`);
    }

    return project;
  }

  async updateStatus(id: number, status: ProjectStatus) {
    const project = await this.findOne(id);
    project.status = status;
    await this.projectRepo.save(project);
    return this.findOne(id);
  }
}
