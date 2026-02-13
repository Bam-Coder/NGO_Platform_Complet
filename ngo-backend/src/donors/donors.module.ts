import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Donor } from './donor.entity';
import { DonorsService } from './donors.service';
import { DonorsController } from './donors.controller';
import { ProjectsModule } from '../projects/projects.module';

@Module({
  imports: [TypeOrmModule.forFeature([Donor]), ProjectsModule],
  providers: [DonorsService],
  controllers: [DonorsController],
  exports: [DonorsService],
})
export class DonorsModule {}
