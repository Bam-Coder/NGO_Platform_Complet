// import { Controller, Post, Get, Body, Param, UseGuards } from '@nestjs/common';
// import { BudgetsService } from './budgets.service';
// import { JwtAuthGuard } from '../auth/jwt-auth.guard';
// import { RolesGuard } from '../auth/roles.guard';
// import { Roles } from '../auth/roles.decorator';

// @Controller('budgets')
// @UseGuards(JwtAuthGuard, RolesGuard)
// export class BudgetsController {
//   constructor(private budgetsService: BudgetsService) {}

//   @Post(':projectId')
//   @Roles('ADMIN')
//     create(@Param('projectId') projectId: number, @Body() budgetData: any) {
//     return this.budgetsService.create({ ...budgetData, project: { id: projectId } });
// }

//   @Get()
//   findAll() {
//     return this.budgetsService.findAll();
//   }
// }
import { Controller, Post, Get, Body, Param, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { BudgetsService } from './budgets.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { Role as UserRole } from '../auth/roles.enum';
import { CreateBudgetDto } from './dto/create-budget.dto';

@ApiTags('Budgets')
@ApiBearerAuth('JWT-auth')
@Controller('budgets')
@UseGuards(JwtAuthGuard, RolesGuard)
export class BudgetsController {
  constructor(private budgetsService: BudgetsService) {}

  @Post(':projectId')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create budget for a project (ADMIN)' })
  create(
    @Param('projectId') projectId: number,
    @Body() dto: CreateBudgetDto,
  ) {
    return this.budgetsService.create(projectId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all budgets' })
  findAll() {
    return this.budgetsService.findAll();
  }

  @Get('project/:projectId')
  @ApiOperation({ summary: 'Get budgets for a project' })
  findByProject(
    @Param('projectId') projectId: number,
    @Req() req: { user: { userId: number; role: UserRole } },
  ) {
    return this.budgetsService.findByProjectId(projectId, req.user);
  }
}
