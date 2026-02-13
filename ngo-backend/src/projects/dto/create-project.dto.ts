import { ApiProperty } from '@nestjs/swagger';
import {
  IsDateString,
  IsNotEmpty,
  IsNumber,
  IsString,
  IsArray,
  IsOptional,
  IsInt,
  IsEnum,
  MinLength,
  Min
} from 'class-validator';
import { ProjectStatus } from '../project-status.enum';

export class CreateProjectDto {

  @ApiProperty({
    example: 'Projet Eau Potable',
    description: 'Project name'
  })
  @IsNotEmpty({ message: 'Project name is required' })
  @IsString()
  @MinLength(3)
  name: string;

  @ApiProperty({
    example: 'Accès à l\'eau potable en zone rurale',
    description: 'Detailed project description'
  })
  @IsNotEmpty({ message: 'Description is required' })
  @IsString()
  description: string;

  @ApiProperty({
    example: 'District de Koulikoro, Mali',
    description: 'Physical location of the project'
  })
  @IsNotEmpty({ message: 'Location is required' })
  @IsString()
  location: string;

  @ApiProperty({
    example: '2026-02-10',
    description: 'Project start date (YYYY-MM-DD)'
  })
  @IsNotEmpty({ message: 'Start date is required' })
  @IsDateString()
  startDate: string;

  @ApiProperty({
    example: '2026-12-31',
    description: 'Project end date (YYYY-MM-DD)',
    required: false
  })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiProperty({
    example: 50000000,
    description: 'Total project budget in currency units'
  })
  @IsNotEmpty({ message: 'Total budget is required' })
  @IsNumber({}, { message: 'Budget must be a number' })
  @Min(0, { message: 'Budget must be greater than 0' })
  budgetTotal: number;

  @ApiProperty({
    example: 'XOF',
    description: 'ISO 4217 currency code (XOF, USD, EUR, etc.)',
    default: 'USD'
  })
  @IsOptional()
  @IsString({ message: 'Currency must be a 3-letter ISO code' })
  currency?: string;

  @ApiProperty({
    example: 1,
    description: 'User ID of project manager',
    type: 'number'
  })
  @IsNotEmpty({ message: 'Manager ID is required' })
  @IsInt()
  managerId: number;

  @ApiProperty({
    example: [1, 2, 3],
    description: 'Array of donor IDs funding this project',
    type: 'array',
    items: { type: 'number' },
    required: false
  })
  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  donorIds?: number[];

  @ApiProperty({
    example: 'PLANNED',
    enum: ProjectStatus,
    description: 'Project status',
    required: false,
    default: ProjectStatus.PLANNED
  })
  @IsOptional()
  @IsEnum(ProjectStatus)
  status?: ProjectStatus;
}
