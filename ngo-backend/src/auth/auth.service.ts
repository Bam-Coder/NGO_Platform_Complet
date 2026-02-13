// import { Injectable, UnauthorizedException } from '@nestjs/common';
// import { UsersService } from '../users/users.service';
// import { JwtService } from '@nestjs/jwt';
// import * as bcrypt from 'bcrypt';

// @Injectable()
// export class AuthService {
//   constructor(
//     private usersService: UsersService,
//     private jwtService: JwtService,
//   ) {}

//   async register(data: any) {
//     const hashedPassword = await bcrypt.hash(data.password, 10);
//     const user = await this.usersService.create({
//       ...data,
//       password: hashedPassword,
//     });
//     return user;
//   }

//   async login(email: string, password: string) {
//     const user = await this.usersService.findByEmail(email);
//     if (!user) throw new UnauthorizedException('Invalid credentials');

//     const match = await bcrypt.compare(password, user.password);
//     if (!match) throw new UnauthorizedException('Invalid credentials');

//     const payload = { sub: user.id, role: user.role };
//     return {
//       access_token: this.jwtService.sign(payload),
//     };
//   }
// }
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { BadRequestException } from '@nestjs/common';
import { Role } from './roles.enum';
@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const existingUser = await this.usersService.findByEmail(dto.email);

    if (existingUser) {
      throw new BadRequestException('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);

    // 🔒 SECURITY: Use provided role or default to AGENT
    // In a real app, validate that only ADMIN can assign FINANCE/ADMIN roles
    // For now, allow any role in DTO - add @Req/@AuthGuard to restrict
    const userRole = dto.role || Role.AGENT;

    const user = await this.usersService.create({
      name: dto.name,
      email: dto.email,
      password: hashedPassword,
      role: userRole, // Use role from DTO or default to AGENT
    });

    return {
      message: 'User registered successfully',
      userId: user.id,
    };
  }

  async login(dto: LoginDto) {
    const user = await this.usersService.findByEmail(dto.email);

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(
      dto.password,
      user.password,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = {
      sub: user.id,
      role: user.role,
    };

    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}
