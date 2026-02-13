import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Budget } from '../budgets/budget.entity';
import { Project } from '../projects/project.entity';
import { User } from '../users/user.entity';
import { ExpenseStatus } from './expense-status.enum';

@Entity()
export class Expense {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Project, (project) => project.expenses, {
    onDelete: 'CASCADE',
    eager: true,
  })
  project: Project;

  @ManyToOne(() => Budget, { onDelete: 'CASCADE', eager: true })
  budget: Budget; // Budget category relationship

  @Column('decimal', { precision: 15, scale: 2 })
  amount: number;

  @Column('text')
  description: string;

  @Column({ type: 'date' })
  date: string; // When the expense occurred

  @Column({ nullable: true, type: 'text' })
  receiptUrl: string; // URL to receipt image (S3/Cloudinary, not base64)

  @Column('decimal', { precision: 10, scale: 6, nullable: true })
  gpsLat: number; // GPS latitude (proof of field work)

  @Column('decimal', { precision: 10, scale: 6, nullable: true })
  gpsLng: number; // GPS longitude (proof of field work)

  @Column({
    type: 'enum',
    enum: ExpenseStatus,
    default: ExpenseStatus.PENDING,
  })
  status: ExpenseStatus; // Approval status

  @ManyToOne(() => User, { nullable: true })
  createdBy: User; // Who created this expense (Agent)

  @ManyToOne(() => User, { nullable: true })
  approvedBy: User; // Who approved this expense (Finance/Admin)

  @Column({ nullable: true, type: 'date' })
  approvedAt: Date; // When the expense was approved

  @Column({ nullable: true, type: 'text' })
  approvalComment: string; // Audit justification

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
