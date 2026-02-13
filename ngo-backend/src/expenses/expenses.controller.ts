import { Controller, Post, Get, Body, Param, UseGuards, Patch, Req } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { ExpensesService } from './expenses.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { Role as UserRole } from '../auth/roles.enum';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { ApproveExpenseDto } from './dto/approve-expense.dto';

@ApiTags('Expenses')
@ApiBearerAuth('JWT-auth')
@Controller('expenses')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ExpensesController {
  constructor(private expensesService: ExpensesService) {}

  @Post(':projectId/:budgetId')
  @Roles(UserRole.ADMIN, UserRole.AGENT)
  @ApiOperation({ summary: 'Add expense to a project and budget' })
  create(
    @Param('projectId') projectId: number,
    @Param('budgetId') budgetId: number,
    @Body() dto: CreateExpenseDto,
  ) {
    return this.expensesService.create(projectId, budgetId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all expenses' })
  findAll(@Req() req: { user: { userId: number; role: UserRole } }) {
    return this.expensesService.findAllForUser(req.user);
  }

  @Patch(':id/approve')
  @Roles(UserRole.ADMIN, UserRole.FINANCE)
  @ApiOperation({ summary: 'Approve or reject an expense (ADMIN/FINANCE)' })
  approve(
    @Param('id') id: number,
    @Body() dto: ApproveExpenseDto,
    @Req() req: { user: { userId: number; role: UserRole } },
  ) {
    return this.expensesService.approve(id, dto, req.user.userId);
  }
}
