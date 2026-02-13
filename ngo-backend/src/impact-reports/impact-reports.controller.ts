import { Controller, Post, Get, Body, Param, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { ImpactReportsService } from './impact-reports.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { Role as UserRole } from '../auth/roles.enum';
import { CreateImpactReportDto } from './dto/create-impact-reports.dto';

@ApiTags('Impact Reports')
@ApiBearerAuth('JWT-auth')
@Controller('impact-reports')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ImpactReportsController {
  constructor(private reportsService: ImpactReportsService) {}

  @Post(':projectId/:userId')
  @Roles(UserRole.ADMIN, UserRole.AGENT)
  @ApiOperation({ summary: 'Create impact report' })
  create(
    @Param('projectId') projectId: number,
    @Param('userId') userId: number,
    @Body() dto: CreateImpactReportDto,
  ) {
    return this.reportsService.create(projectId, userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all impact reports' })
  findAll(@Req() req: { user: { userId: number; role: UserRole } }) {
    return this.reportsService.findAllForUser(req.user);
  }

}
