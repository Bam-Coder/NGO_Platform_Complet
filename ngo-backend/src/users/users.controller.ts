// import { Controller, Get, UseGuards } from '@nestjs/common';
// import { JwtAuthGuard } from '../auth/jwt-auth.guard';
// import { RolesGuard } from '../auth/roles.guard';
// import { Roles } from '../auth/roles.decorator';

// @Controller('users')
// @UseGuards(JwtAuthGuard, RolesGuard)
// export class UsersController {

//   @Get()
//   @Roles('ADMIN')
//   findAllUsers() {
//     return 'Seulement ADMIN peut voir ceci';
//   }
// }
import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { Role as UserRole } from '../auth/roles.enum';
import { UsersService } from './users.service';

@ApiTags('Users')
@ApiBearerAuth('JWT-auth')
@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get()
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all users (ADMIN only)' })
  findAllUsers() {
    return this.usersService.findAll();
  }
}
