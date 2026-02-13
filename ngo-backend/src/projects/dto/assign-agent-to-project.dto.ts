import { ApiProperty } from '@nestjs/swagger';
import {
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

/**
 * DTO for assigning/updating agent to project
 * Used to link agents to specific projects for field management
 */
export class AssignAgentToProjectDto {
  @ApiProperty({
    example: 1,
    description: 'Agent (User) ID to assign to project',
    type: 'number'
  })
  @IsNotEmpty({ message: 'Agent ID is required' })
  @IsInt({ message: 'Agent ID must be an integer' })
  agentId: number;

  @ApiProperty({
    example: 'field_coordinator',
    description: 'Role of the agent in this project',
    required: false
  })
  @IsOptional()
  @IsString({ message: 'Agent role must be a string' })
  agentRole?: string;
}
