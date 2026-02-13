import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  ManyToOne,
  ManyToMany,
  JoinTable,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Budget } from 'src/budgets/budget.entity';
import { Expense } from 'src/expenses/expense.entity';
import { ImpactReport } from 'src/impact-reports/impact-report.entity';
import { User } from 'src/users/user.entity';
import { Donor } from 'src/donors/donor.entity';
import { ProjectStatus } from './project-status.enum';

@Entity()
export class Project {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  name: string;

  @Column('text', { nullable: true })
  description: string;

  @Column({ nullable: true })
  location: string; // WHERE?

  @Column({ type: 'date', nullable: true })
  startDate: string;

  @Column({ type: 'date', nullable: true })
  endDate: string;

  @Column('decimal', { precision: 15, scale: 2, nullable: true })
  budgetTotal: number; // HOW MUCH?

  @Column({ default: 'USD', type: 'varchar', length: 3 })
  currency: string; // ISO 4217 currency code (USD, EUR, XOF, etc.)

  @Column('decimal', { precision: 15, scale: 2, default: 0 })
  budgetSpent: number; // Tracking

  @ManyToOne(() => User, { eager: true, nullable: true })
  manager: User; // WHO manages?

  @ManyToMany(() => Donor, (donor) => donor.projects, { cascade: true })
  @JoinTable()
  donors: Donor[]; // FUNDED BY?

  @OneToMany(() => Budget, (budget) => budget.project, { cascade: true })
  budgets: Budget[];

  @OneToMany(() => Expense, (expense) => expense.project, { cascade: true })
  expenses: Expense[];

  @OneToMany(() => ImpactReport, (report) => report.project, { cascade: true })
  reports: ImpactReport[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({
    type: 'enum',
    enum: ProjectStatus,
    default: ProjectStatus.PLANNED,
  })
  status: ProjectStatus;
}
