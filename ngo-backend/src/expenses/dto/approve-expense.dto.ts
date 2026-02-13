import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ExpenseStatus } from '../expense-status.enum';

/**
 * DTO for Finance/Admin to approve or reject expenses
 * Users CANNOT provide their own approval status or createdBy
 * These are assigned by the system based on authenticated user
 */
export class ApproveExpenseDto {
  @ApiProperty({
    enum: ExpenseStatus,
    example: ExpenseStatus.APPROVED,
    description: 'Approval decision: APPROVED or REJECTED',
    enumName: 'ExpenseStatus'
  })
  @IsNotEmpty({ message: 'Status is required' })
  @IsEnum(ExpenseStatus, { message: 'Status must be APPROVED or REJECTED' })
  status: ExpenseStatus;

  @ApiProperty({
    example: 'Receipt verified. All documents in order.',
    description: 'Optional comment explaining the approval/rejection decision',
    required: false
  })
  @IsOptional()
  @IsString({ message: 'Comment must be a string' })
  approvalComment?: string;
}
