// import { ApiProperty } from '@nestjs/swagger';

// export class RegisterDto {
//   @ApiProperty({ example: 'John Doe' })
//   name: string;

//   @ApiProperty({ example: 'john@email.com' })
//   email: string;

//   @ApiProperty({ example: 'password123' })
//   password: string;
// }
import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, MinLength, IsEnum, IsOptional } from 'class-validator';
import { Role } from '../roles.enum';

export class RegisterDto {
  @ApiProperty({ example: 'John Doe', description: 'Full name of the user' })
  @IsNotEmpty({ message: 'Name is required' })
  name: string;

  @ApiProperty({ 
    example: 'john@email.com', 
    description: 'Valid email address' 
  })
  @IsEmail({}, { message: 'Must be a valid email' })
  @IsNotEmpty({ message: 'Email is required' })
  email: string;

  @ApiProperty({ 
    example: 'password123', 
    description: 'Minimum 6 characters' 
  })
  @IsNotEmpty({ message: 'Password is required' })
  @MinLength(6, { message: 'Password must be at least 6 characters' })
  password: string;

  @ApiProperty({
    enum: Role,
    example: Role.AGENT,
    description: 'User role (only ADMIN can assign non-AGENT roles)',
    default: Role.AGENT,
    required: false
  })
  @IsOptional()
  @IsEnum(Role, { message: 'Role must be a valid Role' })
  role?: Role = Role.AGENT;

  // 🔒 NOTE: role can be provided but will be validated by AuthService
  // Only requests from ADMIN users can assign FINANCE, ADMIN roles
  // Regular self-registration defaults to AGENT
}
