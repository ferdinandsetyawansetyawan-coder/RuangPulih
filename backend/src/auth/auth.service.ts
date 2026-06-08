import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { ActivityLogsService } from '../activity-logs/activity-logs.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private activityLogsService: ActivityLogsService,
  ) {}

  async register(email: string, pass: string, fullName?: string) {
    const existingUser = await this.usersService.findByEmail(email);
    if (existingUser) {
      throw new ConflictException('Email already registered');
    }

    const hashedPassword = await bcrypt.hash(pass, 10);
    const user = await this.usersService.create({
      email,
      password: hashedPassword,
      fullName,
    });

    await this.activityLogsService.log(
      user.id,
      'REGISTER',
      `User registered with email: ${email}`,
    );

    const { password, ...result } = user;
    return result;
  }

  async validateUser(email: string, pass: string): Promise<any> {
    const user = await this.usersService.findByEmail(email);
    if (user && (await bcrypt.compare(pass, user.password))) {
      const { password, ...result } = user;
      return result;
    }

    // Log failed login attempt
    await this.activityLogsService.log(
      null,
      'LOGIN_FAILED',
      `Failed login attempt for email: ${email}`,
    );
    return null;
  }

  async login(user: any) {
    const payload = { email: user.email, sub: user.id };

    // Log successful login
    await this.activityLogsService.log(
      user.id,
      'LOGIN_SUCCESS',
      `User logged in: ${user.email}`,
    );

    return {
      access_token: this.jwtService.sign(payload),
      user: user,
    };
  }
}
