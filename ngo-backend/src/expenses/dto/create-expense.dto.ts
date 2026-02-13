// import { ApiProperty } from '@nestjs/swagger';

// export class CreateExpenseDto {
//   @ApiProperty({ example: 20000 })
//   amount: number;

//   @ApiProperty({ example: 'Achat matériel' })
//   description: string;
// }
import { ApiProperty } from '@nestjs/swagger';
import {
  IsNumber,
  IsString,
  IsDateString,
  IsNotEmpty,
  IsOptional,
  IsInt,
  Min
} from 'class-validator';

export class CreateExpenseDto {
  @ApiProperty({
    example: 1,
    description: 'Project ID associated with this expense',
    type: 'number'
  })
  @IsNotEmpty({ message: 'Project ID is required' })
  @IsInt()
  projectId: number;

  @ApiProperty({
    example: 1,
    description: 'Budget category ID this expense belongs to',
    type: 'number'
  })
  @IsNotEmpty({ message: 'Budget category ID is required' })
  @IsInt()
  budgetCategoryId: number;

  @ApiProperty({
    example: 20000,
    description: 'Expense amount'
  })
  @IsNotEmpty({ message: 'Amount is required' })
  @IsNumber({}, { message: 'Amount must be a number' })
  @Min(0, { message: 'Amount must be greater than 0' })
  amount: number;

  @ApiProperty({
    example: 'Purchase of medical supplies',
    description: 'Detailed description of the expense'
  })
  @IsNotEmpty({ message: 'Description is required' })
  @IsString()
  description: string;

  @ApiProperty({
    example: '2026-02-04',
    description: 'Date of the expense (YYYY-MM-DD)'
  })
  @IsNotEmpty({ message: 'Expense date is required' })
  @IsDateString()
  date: string;

  @ApiProperty({
    example: 'https://s3.amazonaws.com/receipt-123.jpg',
    description: 'Receipt image URL (S3/Cloudinary, not base64)',
    required: false
  })
  @IsOptional()
  @IsString()
  receiptUrl?: string;

  @ApiProperty({
    example: 12.6452,
    description: 'GPS latitude coordinate (proof of field work)',
    required: false
  })
  @IsOptional()
  @IsNumber()
  gpsLat?: number;

  @ApiProperty({
    example: -8.0076,
    description: 'GPS longitude coordinate (proof of field work)',
    required: false
  })
  @IsOptional()
  @IsNumber()
  gpsLng?: number;
}
