import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Project } from '../projects/project.entity';
import { User } from '../users/user.entity';

@Entity()
export class ImpactReport {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Project, (project) => project.reports, {
    onDelete: 'CASCADE',
    eager: true,
  })
  project: Project;

  @Column()
  title: string;

  @Column('text')
  description: string;

  @Column({
    type: 'bigint',
    nullable: true,
    default: 0,
    transformer: {
      to: (value: number) => value,
      from: (value: string) => (value == null ? null : Number(value)),
    },
  })
  beneficiariesCount: number; // How many people were helped (KPI)

  @Column('text')
  activitiesDone: string; // What activities were completed

  @Column('simple-array', { nullable: true })
  photos: string[]; // Array of photo URLs (S3/Cloudinary, not base64)

  @Column('decimal', { precision: 10, scale: 6, nullable: true })
  gpsLat: number; // GPS latitude (location proof)

  @Column('decimal', { precision: 10, scale: 6, nullable: true })
  gpsLng: number; // GPS longitude (location proof)

  @Column({ type: 'date' })
  date: string; // Report date

  @Column({ default: false })
  verified: boolean; // Finance/Admin validates impact proof

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  verifiedBy: User; // Who verified this report

  @ManyToOne(() => User, { onDelete: 'SET NULL', nullable: true })
  createdBy: User;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
