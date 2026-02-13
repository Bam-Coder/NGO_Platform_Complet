// import { Controller, Post, Get, Body, Param, UseGuards } from '@nestjs/common';
// import { ProjectsService } from './projects.service';
// import { JwtAuthGuard } from '../auth/jwt-auth.guard';
// import { RolesGuard } from '../auth/roles.guard';
// import { Roles } from '../auth/roles.decorator';

// @Controller('projects')
// @UseGuards(JwtAuthGuard, RolesGuard)
// export class ProjectsController {
//   constructor(private projectsService: ProjectsService) {}

//   @Post()
//   @Roles('ADMIN')
//   create(@Body() projectData: any) {
//     return this.projectsService.create(projectData);
//   }

//   @Get()
//   findAll() {
//     return this.projectsService.findAll();
//   }

//   @Get(':id')
//   findOne(@Param('id') id: number) {
//     return this.projectsService.findOne(id);
//   }
// }
import { Controller, Get, Post, Body, UseGuards, Req, Patch, Param } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { ProjectsService } from './projects.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { Role as UserRole } from '../auth/roles.enum';
import { CreateProjectDto } from './dto/create-project.dto';
import { UpdateProjectStatusDto } from './dto/update-project-status.dto';

@ApiTags('Projects')
@ApiBearerAuth('JWT-auth')
@Controller('projects')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ProjectsController {
  constructor(private projectsService: ProjectsService) {}

  @Post()
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create a project (ADMIN only)' })
  create(@Body() dto: CreateProjectDto) {
    return this.projectsService.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all projects' })
  findAll(@Req() req: { user: { userId: number; role: UserRole } }) {
    return this.projectsService.findAllForUser(req.user);
  }

  @Patch(':id/status')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update project status (ADMIN only)' })
  updateStatus(@Param('id') id: number, @Body() dto: UpdateProjectStatusDto) {
    return this.projectsService.updateStatus(Number(id), dto.status);
  }
}
