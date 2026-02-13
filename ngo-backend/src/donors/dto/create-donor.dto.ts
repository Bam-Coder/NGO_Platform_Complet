// import { ApiProperty } from '@nestjs/swagger';
// export class CreateDonorDto {
//   @ApiProperty({ example: 'UNICEF' })
//   name: string;

//   @ApiProperty({ example: 'Organisation internationale' })
//   description: string;
// }
import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsString,
  IsOptional,
  IsNumber,
  IsEnum,
  Length,
  Min
} from 'class-validator';
import { DonorType } from '../donor.entity';

export class CreateDonorDto {
  @ApiProperty({
    example: 'UNICEF',
    description: 'Donor organization or individual name'
  })
  @IsNotEmpty({ message: 'Name is required' })
  @IsString()
  name: string;

  @ApiProperty({
    example: 'contact@unicef.org',
    description: 'Donor email address'
  })
  @IsNotEmpty({ message: 'Email is required' })
  @IsEmail({}, { message: 'Must be a valid email' })
  email: string;

  @ApiProperty({
    example: '+22670000000',
    description: 'Donor phone number',
    required: false
  })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiProperty({
    example: 'UNICEF Mali',
    description: 'Organization name (for institutional donors)',
    required: false
  })
  @IsOptional()
  @IsString()
  organization?: string;

  @ApiProperty({
    example: 'institutional',
    enum: DonorType,
    description: 'Donor type: individual or institutional',
    required: false
  })
  @IsOptional()
  @IsEnum(DonorType, { message: 'Type must be individual or institutional' })
  type?: DonorType;

  @ApiProperty({
    example: 10000000,
    description: 'Total amount funded by this donor',
    required: false
  })
  @IsOptional()
  @IsNumber({}, { message: 'Funded amount must be a number' })
  @Min(0)
  fundedAmount?: number;

  @ApiProperty({
    example: 'ML',
    description: 'Country code (ISO 3166-1 alpha-2), e.g., US, FR, ML',
    required: false
  })
  @IsOptional()
  @IsString()
  @Length(2, 2, { message: 'Country code must be 2 characters' })
  country?: string;

  @ApiProperty({
    example: 'XOF',
    description: 'Currency code (ISO 4217), e.g., USD, EUR, XOF',
    required: false,
    default: 'USD'
  })
  @IsOptional()
  @IsString()
  @Length(3, 3, { message: 'Currency code must be 3 characters' })
  currency?: string;
}
