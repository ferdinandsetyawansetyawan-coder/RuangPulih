import { Test, TestingModule } from '@nestjs/testing';
import { MoodsController } from './moods.controller';
import { MoodsService } from './moods.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ExecutionContext } from '@nestjs/common';

describe('MoodsController', () => {
  let controller: MoodsController;
  let mockMoodsService = {
    create: jest.fn(),
    findLatestByUser: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [MoodsController],
      providers: [
        {
          provide: MoodsService,
          useValue: mockMoodsService,
        },
      ],
    })
    .overrideGuard(JwtAuthGuard)
    .useValue({ canActivate: (context: ExecutionContext) => true })
    .compile();

    controller = module.get<MoodsController>(MoodsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('create', () => {
    it('should call moodsService.create', async () => {
      const body = { userId: 1, label: 'Happy', emoji: '😊' };
      await controller.create(body);
      expect(mockMoodsService.create).toHaveBeenCalledWith(body.userId, {
        label: body.label,
        emoji: body.emoji,
      });
    });
  });

  describe('findLatest', () => {
    it('should call moodsService.findLatestByUser', async () => {
      const userId = '1';
      await controller.findLatest(userId);
      expect(mockMoodsService.findLatestByUser).toHaveBeenCalledWith(1);
    });
  });
});
