import { Test, TestingModule } from '@nestjs/testing';
import { ActivityLogsController } from './activity-logs.controller';
import { ActivityLogsService } from './activity-logs.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ExecutionContext } from '@nestjs/common';

describe('ActivityLogsController', () => {
  let controller: ActivityLogsController;
  const mockActivityLogsService = {
    findAll: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ActivityLogsController],
      providers: [
        {
          provide: ActivityLogsService,
          useValue: mockActivityLogsService,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({ canActivate: (context: ExecutionContext) => true })
      .compile();

    controller = module.get<ActivityLogsController>(ActivityLogsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('findAll', () => {
    it('should call activityLogsService.findAll', async () => {
      await controller.findAll();
      expect(mockActivityLogsService.findAll).toHaveBeenCalled();
    });
  });
});
