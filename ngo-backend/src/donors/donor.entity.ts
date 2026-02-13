import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToMany,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Project } from '../projects/project.entity';

export enum DonorType {
  INDIVIDUAL = 'individual',
  INSTITUTIONAL = 'institutional',
}

@Entity()
export class Donor {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({ unique: true })
  email: string;

  @Column({ nullable: true })
  phone: string;

  @Column({ nullable: true })
  organization: string; // Organization name (for institutional donors)

  @Column({
    type: 'enum',
    enum: DonorType,
    default: DonorType.INDIVIDUAL,
  })
  type: DonorType; // individual or institutional

  @Column('decimal', { precision: 15, scale: 2, default: 0 })
  fundedAmount: number; // Total amount funded by this donor

  @Column({ nullable: true })
  country: string; // Country of donor (for multi-country NGOs)

  @Column({ nullable: true, default: 'USD' })
  currency: string; // Currency code (USD, EUR, GBP, etc.)

  @ManyToMany(() => Project, (project) => project.donors)
  projects: Project[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
