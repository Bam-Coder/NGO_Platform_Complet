// import { Injectable, NotFoundException } from '@nestjs/common';
// import { InjectRepository } from '@nestjs/typeorm';
// import { Repository } from 'typeorm';
// import { Budget } from './budget.entity';

// @Injectable()
// export class BudgetsService {
//   constructor(
//     @InjectRepository(Budget)
//     private budgetRepo: Repository<Budget>,
//   ) {}

//   async create(data: Partial<Budget>) {
//     const budget = this.budgetRepo.create(data);
//     return this.budgetRepo.save(budget);
//   }

//   findAll() {
//     return this.budgetRepo.find({ relations: ['project'] });
//   }

//   // <-- Ajoute cette méthode
//   async findOne(id: number) {
//     const budget = await this.budgetRepo.findOne({ where: { id }, relations: ['project'] });
//     if (!budget) throw new NotFoundException(`Budget with id ${id} not found`);
//     return budget;
//   }
// }
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Budget, BudgetCategory } from './budget.entity';
import { ProjectsService } from '../projects/projects.service';
import { CreateBudgetDto } from './dto/create-budget.dto';
import { Role as UserRole } from '../auth/roles.enum';

@Injectable()
export class BudgetsService {
  constructor(
    @InjectRepository(Budget)
    private budgetRepo: Repository<Budget>,
    private projectsService: ProjectsService,
  ) {}

  async create(projectId: number, data: CreateBudgetDto) {
    const project = await this.projectsService.findOne(projectId);

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    const budget = this.budgetRepo.create({
      project,
      category: data.category as BudgetCategory,
      allocatedAmount: data.allocatedAmount,
      description: data.description,
    });

    return this.budgetRepo.save(budget);
  }

  findAll() {
    return this.budgetRepo.find({ relations: ['project'] });
  }

  findByProjectId(projectId: number, user: { userId: number; role: UserRole }) {
    if (user.role === UserRole.ADMIN) {
      return this.budgetRepo.find({
        where: { project: { id: projectId } },
        relations: ['project'],
      });
    }

    return this.budgetRepo
      .createQueryBuilder('budget')
      .leftJoinAndSelect('budget.project', 'project')
      .leftJoin('project.manager', 'manager')
      .where('project.id = :projectId', { projectId })
      .andWhere('manager.id = :userId', { userId: user.userId })
      .getMany();
  }

  async findOne(id: number) {
    const budget = await this.budgetRepo.findOne({
      where: { id },
      relations: ['project'],
    });

    if (!budget) {
      throw new NotFoundException('Budget not found');
    }

    return budget;
  }
}
