import { ApiProperty } from '@nestjs/swagger';
import {
  IsBoolean,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

/**
 * DTO for Finance/Admin to verify impact reports
 * Only verified and verification comment can be provided
 * verifiedBy is assigned by the system based on authenticated user
 */
export class VerifyImpactReportDto {
  @ApiProperty({
    example: true,
    description: 'Whether the impact report has been verified as accurate'
  })
  @IsNotEmpty({ message: 'Verification status is required' })
  @IsBoolean({ message: 'Verified must be a boolean' })
  verified: boolean;

  @ApiProperty({
    example: 'Data verified with field officer. Beneficiary count confirmed.',
    description: 'Optional comment explaining the verification decision',
    required: false
  })
  @IsOptional()
  @IsString({ message: 'Comment must be a string' })
  verificationComment?: string;
}
