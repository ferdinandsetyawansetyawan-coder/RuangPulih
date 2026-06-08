import { Test, TestingModule } from '@nestjs/testing';
import { ActivityLogsService } from './activity-logs.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ActivityLog } from './entities/activity-log.entity';

describe('ActivityLogsService', () => {
  let service: ActivityLogsService;
  const mockRepository = {
    create: jest.fn(),
    save: jest.fn(),
    find: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ActivityLogsService,
        {
          provide: getRepositoryToken(ActivityLog),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<ActivityLogsService>(ActivityLogsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('log', () => {
    it('should create and save a log entry', async () => {
      const userId = 1;
      const action = 'TEST_ACTION';
      const description = 'Test description';

      mockRepository.create.mockReturnValue({ userId, action, description });
      mockRepository.save.mockResolvedValue({
        id: 1,
        userId,
        action,
        description,
      });

      const result = await service.log(userId, action, description);
      expect(result).toEqual({ id: 1, userId, action, description });
      expect(mockRepository.create).toHaveBeenCalledWith({
        userId,
        action,
        description,
        ipAddress: undefined,
      });
      expect(mockRepository.save).toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
    it('should return recent logs', async () => {
      const logs = [{ id: 1, action: 'TEST' }];
      mockRepository.find.mockResolvedValue(logs);

      const result = await service.findAll();
      expect(result).toEqual(logs);
      expect(mockRepository.find).toHaveBeenCalledWith({
        order: { createdAt: 'DESC' },
        take: 100,
      });
    });
  });
});
