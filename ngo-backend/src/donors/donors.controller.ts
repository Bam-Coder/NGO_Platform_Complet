// import { Controller, Post, Get, Body, Param, UseGuards } from '@nestjs/common';
// import { DonorsService } from './donors.service';
// import { JwtAuthGuard } from '../auth/jwt-auth.guard';
// import { RolesGuard } from '../auth/roles.guard';
// import { Roles } from '../auth/roles.decorator';

// @Controller('donors')
// @UseGuards(JwtAuthGuard, RolesGuard)
// export class DonorsController {
//   constructor(private donorsService: DonorsService) {}

//   @Post()
//   @Roles('ADMIN')
//   create(@Body() donorData: any) {
//     return this.donorsService.create(donorData);
//   }

//   @Get()
//   findAll() {
//     return this.donorsService.findAll();
//   }

//   @Get(':id')
//   findOne(@Param('id') id: number) {
//     return this.donorsService.findOne(id);
//   }
// }
import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { DonorsService } from './donors.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { Role as UserRole } from '../auth/roles.enum';
import { CreateDonorDto } from './dto/create-donor.dto';

@ApiTags('Donors')
@ApiBearerAuth('JWT-auth')
@Controller('donors')
@UseGuards(JwtAuthGuard, RolesGuard)
export class DonorsController {
  constructor(private donorsService: DonorsService) {}

  @Post()
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create a donor (ADMIN only)' })
  create(@Body() dto: CreateDonorDto) {
    return this.donorsService.create(dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all donors' })
  findAll() {
    return this.donorsService.findAll();
  }
}
