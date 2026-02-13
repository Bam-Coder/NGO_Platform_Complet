import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsArray,
  IsDateString,
  IsInt,
  Min
} from 'class-validator';

export class CreateImpactReportDto {
  @ApiProperty({
    example: 1,
    description: 'Project ID this report is about',
    type: 'number'
  })
  @IsNotEmpty({ message: 'Project ID is required' })
  @IsInt()
  projectId: number;

  @ApiProperty({
    example: 'Impact du projet Eau Potable',
    description: 'Report title'
  })
  @IsNotEmpty({ message: 'Title is required' })
  @IsString()
  title: string;

  @ApiProperty({
    example: 'The water project successfully reached 500 families in rural Mali',
    description: 'Detailed report description'
  })
  @IsNotEmpty({ message: 'Description is required' })
  @IsString()
  description: string;

  @ApiProperty({
    example: 500,
    description: 'Number of beneficiaries reached (critical for donors)'
  })
  @IsNotEmpty({ message: 'Beneficiaries count is required' })
  @IsNumber({}, { message: 'Beneficiaries count must be a number' })
  @Min(0)
  beneficiariesCount: number;

  @ApiProperty({
    example: 'Installed 5 water wells, trained 20 local technicians, provided hygiene education to 200 children',
    description: 'Summary of activities completed'
  })
  @IsNotEmpty({ message: 'Activities description is required' })
  @IsString()
  activitiesDone: string;

  @ApiProperty({
    example: ['https://s3.amazonaws.com/photo1.jpg', 'https://s3.amazonaws.com/photo2.jpg'],
    description: 'Array of photo URLs (S3/Cloudinary, not base64)',
    required: false
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  photos?: string[];

  @ApiProperty({
    example: 12.6452,
    description: 'GPS latitude of project location (proof of field work)',
    required: false
  })
  @IsOptional()
  @IsNumber()
  gpsLat?: number;

  @ApiProperty({
    example: -8.0076,
    description: 'GPS longitude of project location (proof of field work)',
    required: false
  })
  @IsOptional()
  @IsNumber()
  gpsLng?: number;

  @ApiProperty({
    example: '2026-02-04',
    description: 'Report date (YYYY-MM-DD)'
  })
  @IsNotEmpty({ message: 'Date is required' })
  @IsDateString()
  date: string;
}
