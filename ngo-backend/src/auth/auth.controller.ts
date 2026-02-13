// import { Controller, Post, Body } from '@nestjs/common';
// import { AuthService } from './auth.service';

// @Controller('auth')
// export class AuthController {
//   constructor(private authService: AuthService) {}

//   @Post('register')
//   register(@Body() body: any) {
//     return this.authService.register(body);
//   }

//   @Post('login')
//   login(@Body() body: any) {
//     return this.authService.login(body.email, body.password);
//   }
// }





// import { Controller, Post, Body } from '@nestjs/common';
// import { ApiTags, ApiOperation } from '@nestjs/swagger';
// import { AuthService } from './auth.service';

// @ApiTags('Auth')
// @Controller('auth')
// export class AuthController {
//   constructor(private authService: AuthService) {}

//   @Post('register')
//   @ApiOperation({ summary: 'Register a new user' })
//   register(@Body() body: any) {
//     return this.authService.register(body);
//   }

//   @Post('login')
//   @ApiOperation({ summary: 'Login user and return JWT' })
//   login(@Body() body: any) {
//     return this.authService.login(body.email, body.password);
//   }
// }
import { Controller, Post, Body } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Register a new user' })
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  @ApiOperation({ summary: 'Login user and return JWT' })
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }
}
