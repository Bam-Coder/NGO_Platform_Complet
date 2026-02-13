import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Project } from '../projects/project.entity';

export enum BudgetCategory {
  TRANSPORT = 'Transport',
  FOOD = 'Food',
  LOGISTICS = 'Logistics',
  TRAINING = 'Training',
  HEALTH = 'Health',
  EDUCATION = 'Education',
  EQUIPMENT = 'Equipment',
  STAFF = 'Staff',
  UTILITIES = 'Utilities',
  OTHER = 'Other',
}

@Entity()
export class Budget {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Project, (project) => project.budgets, {
    onDelete: 'CASCADE',
    eager: true,
  })
  project: Project;

  @Column({
    type: 'enum',
    enum: BudgetCategory,
    default: BudgetCategory.OTHER,
  })
  category: BudgetCategory; // Budget category (Transport, Food, etc.)

  @Column('decimal', { precision: 15, scale: 2 })
  allocatedAmount: number; // Amount allocated to this category

  @Column('decimal', { precision: 15, scale: 2, default: 0 })
  spentAmount: number; // Tracking spent amount

  @Column({ nullable: true })
  description: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
