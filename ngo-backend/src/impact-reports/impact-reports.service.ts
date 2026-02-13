import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ImpactReport } from './impact-report.entity';
import { ProjectsService } from '../projects/projects.service';
import { UsersService } from '../users/users.service';
import { CreateImpactReportDto } from './dto/create-impact-reports.dto';
import { Role as UserRole } from '../auth/roles.enum';
import { normalizeMediaUrls } from '../common/media-url.util';

@Injectable()
export class ImpactReportsService {
  constructor(
    @InjectRepository(ImpactReport)
    private reportRepo: Repository<ImpactReport>,
    private projectsService: ProjectsService,
    private usersService: UsersService,
  ) {}

  async create(
    projectId: number,
    userId: number,
    reportData: CreateImpactReportDto,
  ) {
    const project = await this.projectsService.findOne(projectId);
    const user = await this.usersService.findOne(userId);

    if (!project) throw new NotFoundException('Project not found');
    if (!user) throw new NotFoundException('User not found');

    const report = this.reportRepo.create({
      ...reportData,
      project,
      createdBy: user,
    });
    const saved = await this.reportRepo.save(report);
    return this.normalizeReportMedia(saved);
  }

  findAll() {
    return this.reportRepo
      .find({ relations: ['project', 'createdBy'] })
      .then((items) => items.map((item) => this.normalizeReportMedia(item)));
  }

  findAllForUser(user: { userId: number; role: UserRole }) {
    if (user.role === UserRole.ADMIN) {
      return this.findAll();
    }

    return this.reportRepo
      .createQueryBuilder('report')
      .leftJoinAndSelect('report.project', 'project')
      .leftJoinAndSelect('report.createdBy', 'createdBy')
      .leftJoin('project.manager', 'manager')
      .where('manager.id = :userId', { userId: user.userId })
      .getMany()
      .then((items) => items.map((item) => this.normalizeReportMedia(item)));
  }

  async findOne(id: number) {
    const report = await this.reportRepo.findOne({
      where: { id },
      relations: ['project', 'createdBy'],
    });
    if (!report) throw new NotFoundException('Impact Report not found');
    return this.normalizeReportMedia(report);
  }

  private normalizeReportMedia(report: ImpactReport) {
    if (!report) return report;
    report.photos = normalizeMediaUrls(report.photos);
    return report;
  }
}
