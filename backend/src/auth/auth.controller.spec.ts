import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { UnauthorizedException } from '@nestjs/common';

describe('AuthController', () => {
  let controller: AuthController;
  const mockAuthService = {
    register: jest.fn(),
    validateUser: jest.fn(),
    login: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [{ provide: AuthService, useValue: mockAuthService }],
    }).compile();

    controller = module.get<AuthController>(AuthController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('register', () => {
    it('should call authService.register', async () => {
      const dto = {
        email: 'test@example.com',
        password: 'password',
        fullName: 'Test',
      };
      await controller.register(dto);
      expect(mockAuthService.register).toHaveBeenCalledWith(
        dto.email,
        dto.password,
        dto.fullName,
      );
    });
  });

  describe('login', () => {
    it('should call validateUser and login if valid credentials', async () => {
      const dto = { email: 'test@example.com', password: 'password' };
      const user = { id: 1, email: 'test@example.com' };
      mockAuthService.validateUser.mockResolvedValue(user);
      mockAuthService.login.mockResolvedValue({ access_token: 'token', user });

      const result = await controller.login(dto);
      expect(result).toEqual({ access_token: 'token', user });
      expect(mockAuthService.validateUser).toHaveBeenCalledWith(
        dto.email,
        dto.password,
      );
      expect(mockAuthService.login).toHaveBeenCalledWith(user);
    });

    it('should throw UnauthorizedException if invalid credentials', async () => {
      const dto = { email: 'test@example.com', password: 'wrong-password' };
      mockAuthService.validateUser.mockResolvedValue(null);

      await expect(controller.login(dto)).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });
});
