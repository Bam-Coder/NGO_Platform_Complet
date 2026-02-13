import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ImpactReport } from './impact-report.entity';
import { ImpactReportsService } from './impact-reports.service';
import { ImpactReportsController } from './impact-reports.controller';
import { ProjectsModule } from '../projects/projects.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [TypeOrmModule.forFeature([ImpactReport]), ProjectsModule, UsersModule],
  providers: [ImpactReportsService],
  controllers: [ImpactReportsController],
})
export class ImpactReportsModule {}
