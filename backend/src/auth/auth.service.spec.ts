import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import { ActivityLogsService } from '../activity-logs/activity-logs.service';
import { ConflictException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

jest.mock('bcrypt', () => ({
  hash: jest.fn(),
  compare: jest.fn(),
}));

describe('AuthService', () => {
  let service: AuthService;
  let mockUsersService = {
    findByEmail: jest.fn(),
    create: jest.fn(),
  };
  let mockJwtService = {
    sign: jest.fn(),
  };
  let mockActivityLogsService = {
    log: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UsersService, useValue: mockUsersService },
        { provide: JwtService, useValue: mockJwtService },
        { provide: ActivityLogsService, useValue: mockActivityLogsService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('register', () => {
    it('should throw ConflictException if email already exists', async () => {
      mockUsersService.findByEmail.mockResolvedValue({ id: 1, email: 'test@example.com' });
      await expect(service.register('test@example.com', 'password')).rejects.toThrow(ConflictException);
    });

    it('should create a new user and log activity', async () => {
      mockUsersService.findByEmail.mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashedPassword');
      mockUsersService.create.mockResolvedValue({ id: 1, email: 'test@example.com', password: 'hashedPassword' });
      
      const result = await service.register('test@example.com', 'password', 'Test User');
      
      expect(result).toEqual({ id: 1, email: 'test@example.com' });
      expect(mockActivityLogsService.log).toHaveBeenCalledWith(1, 'REGISTER', expect.any(String));
    });
  });

  describe('validateUser', () => {
    it('should return user without password if validation succeeds', async () => {
      const user = { id: 1, email: 'test@example.com', password: 'hashedPassword' };
      mockUsersService.findByEmail.mockResolvedValue(user);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      const result = await service.validateUser('test@example.com', 'password');
      expect(result).toEqual({ id: 1, email: 'test@example.com' });
    });

    it('should return null and log failure if validation fails', async () => {
      mockUsersService.findByEmail.mockResolvedValue(null);
      
      const result = await service.validateUser('test@example.com', 'password');
      expect(result).toBeNull();
      expect(mockActivityLogsService.log).toHaveBeenCalledWith(null, 'LOGIN_FAILED', expect.any(String));
    });
  });

  describe('login', () => {
    it('should return access token and user information', async () => {
      const user = { id: 1, email: 'test@example.com' };
      mockJwtService.sign.mockReturnValue('test-token');

      const result = await service.login(user);
      
      expect(result).toEqual({
        access_token: 'test-token',
        user: user,
      });
      expect(mockActivityLogsService.log).toHaveBeenCalledWith(1, 'LOGIN_SUCCESS', expect.any(String));
    });
  });
});
