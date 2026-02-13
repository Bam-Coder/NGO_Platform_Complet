import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Expense } from './expense.entity';
import { BudgetsService } from '../budgets/budgets.service';
import { ProjectsService } from '../projects/projects.service';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { ApproveExpenseDto } from './dto/approve-expense.dto';
import { UsersService } from '../users/users.service';
import { Role as UserRole } from '../auth/roles.enum';
import { ExpenseStatus } from './expense-status.enum';
import { Budget } from '../budgets/budget.entity';
import { Project } from '../projects/project.entity';
import { normalizeMediaUrl } from '../common/media-url.util';

@Injectable()
export class ExpensesService {
  constructor(
    @InjectRepository(Expense)
    private expenseRepo: Repository<Expense>,
    private budgetsService: BudgetsService,
    private projectsService: ProjectsService,
    private usersService: UsersService,
  ) {}

  async create(projectId: number, budgetId: number, expenseData: CreateExpenseDto) {
    const project = await this.projectsService.findOne(projectId);
    if (!project) throw new NotFoundException(`Project with id ${projectId} not found`);

    const budget = await this.budgetsService.findOne(budgetId);
    if (!budget) throw new NotFoundException(`Budget with id ${budgetId} not found`);

    const expense = this.expenseRepo.create({
      ...expenseData,
      project,
      budget,
    });
    const saved = await this.expenseRepo.save(expense);
    await this.recalculateSpentAmounts(projectId, budgetId);
    return saved;
  }

  findAll() {
    return this.expenseRepo
      .find({ relations: ['project', 'budget'] })
      .then((items) => items.map((item) => this.normalizeExpenseMedia(item)));
  }

  findAllForUser(user: { userId: number; role: UserRole }) {
    if (user.role === UserRole.ADMIN) {
      return this.findAll();
    }

    return this.expenseRepo
      .createQueryBuilder('expense')
      .leftJoinAndSelect('expense.project', 'project')
      .leftJoinAndSelect('expense.budget', 'budget')
      .leftJoin('project.manager', 'manager')
      .where('manager.id = :userId', { userId: user.userId })
      .getMany()
      .then((items) => items.map((item) => this.normalizeExpenseMedia(item)));
  }

  async findOne(id: number) {
    const expense = await this.expenseRepo.findOne({
      where: { id },
      relations: ['project', 'budget'],
    });
    if (!expense) throw new NotFoundException('Expense not found');
    return this.normalizeExpenseMedia(expense);
  }

  async approve(
    id: number,
    dto: ApproveExpenseDto,
    userId: number,
  ) {
    const expense = await this.expenseRepo.findOne({
      where: { id },
      relations: ['project', 'budget', 'createdBy', 'approvedBy'],
    });
    if (!expense) throw new NotFoundException('Expense not found');

    const approver = await this.usersService.findOne(userId);
    if (!approver) throw new NotFoundException('Approver not found');

    expense.status = dto.status;
    expense.approvedBy = approver;
    expense.approvedAt = new Date();
    expense.approvalComment = dto.approvalComment ?? '';

    const saved = await this.expenseRepo.save(expense);
    await this.recalculateSpentAmounts(saved.project.id, saved.budget.id);
    return this.normalizeExpenseMedia(saved);
  }

  private async recalculateSpentAmounts(projectId: number, budgetId: number) {
    const budgetSumRaw = await this.expenseRepo
      .createQueryBuilder('expense')
      .select('COALESCE(SUM(expense.amount), 0)', 'sum')
      .where('expense.budgetId = :budgetId', { budgetId })
      .andWhere('expense.status = :status', { status: ExpenseStatus.APPROVED })
      .getRawOne<{ sum: string }>();

    const projectSumRaw = await this.expenseRepo
      .createQueryBuilder('expense')
      .select('COALESCE(SUM(expense.amount), 0)', 'sum')
      .where('expense.projectId = :projectId', { projectId })
      .andWhere('expense.status = :status', { status: ExpenseStatus.APPROVED })
      .getRawOne<{ sum: string }>();

    const budgetSpent = Number(budgetSumRaw?.sum ?? 0);
    const projectSpent = Number(projectSumRaw?.sum ?? 0);

    const budgetRepo = this.expenseRepo.manager.getRepository(Budget);
    const projectRepo = this.expenseRepo.manager.getRepository(Project);

    await budgetRepo.update({ id: budgetId }, { spentAmount: budgetSpent });
    await projectRepo.update({ id: projectId }, { budgetSpent: projectSpent });
  }

  private normalizeExpenseMedia(expense: Expense) {
    if (!expense) return expense;
    expense.receiptUrl = normalizeMediaUrl(expense.receiptUrl);
    return expense;
  }
}
