import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsNumber,
  IsString,
  IsInt,
  IsEnum,
  IsOptional,
  Min
} from 'class-validator';
import { BudgetCategory } from '../budget.entity';

export class CreateBudgetDto {
  @ApiProperty({
    example: 1,
    description: 'Project ID this budget belongs to',
    type: 'number'
  })
  @IsNotEmpty({ message: 'Project ID is required' })
  @IsInt()
  projectId: number;

  @ApiProperty({
    example: 'Transport',
    enum: BudgetCategory,
    description: 'Budget category (Transport, Food, Logistics, Training, Health, Education, Equipment, Staff, Utilities, Other)'
  })
  @IsNotEmpty({ message: 'Category is required' })
  @IsEnum(BudgetCategory, { message: 'Category must be a valid BudgetCategory' })
  category: BudgetCategory;

  @ApiProperty({
    example: 5000000,
    description: 'Allocated budget amount for this category'
  })
  @IsNotEmpty({ message: 'Allocated amount is required' })
  @IsNumber({}, { message: 'Amount must be a number' })
  @Min(0, { message: 'Amount must be greater than 0' })
  allocatedAmount: number;

  @ApiProperty({
    example: 'Transportation for beneficiaries',
    description: 'Detailed description of budget allocation',
    required: false
  })
  @IsOptional()
  @IsString()
  description?: string;
}
