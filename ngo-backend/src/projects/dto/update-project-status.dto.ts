import { ApiProperty } from '@nestjs/swagger';
import { IsEnum } from 'class-validator';
import { ProjectStatus } from '../project-status.enum';

export class UpdateProjectStatusDto {
  @ApiProperty({
    enum: ProjectStatus,
    example: ProjectStatus.ACTIVE,
  })
  @IsEnum(ProjectStatus)
  status: ProjectStatus;
}
