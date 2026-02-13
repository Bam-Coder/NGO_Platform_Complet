import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Project } from './project.entity';
import { User } from '../users/user.entity';

/**
 * ProjectAgent - Links agents to projects for field management and accountability
 * Tracks which agents are working on which projects and their roles
 */
@Entity()
export class ProjectAgent {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Project, { onDelete: 'CASCADE', eager: true })
  project: Project;

  @ManyToOne(() => User, { onDelete: 'CASCADE', eager: true })
  agent: User;

  @Column({ nullable: true, type: 'varchar' })
  agentRole: string; // Agent role in project (e.g., 'field_coordinator', 'implementer')

  @Column({ default: true })
  isActive: boolean; // Whether agent is currently active on project

  @CreateDateColumn()
  assignedAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ type: 'date', nullable: true })
  removedAt: Date; // When agent was removed from project
}
