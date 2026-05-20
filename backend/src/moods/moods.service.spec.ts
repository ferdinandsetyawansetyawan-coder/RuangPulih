import { Test, TestingModule } from '@nestjs/testing';
import { MoodsService } from './moods.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Mood } from './entities/mood.entity';

describe('MoodsService', () => {
  let service: MoodsService;
  let mockRepository = {
    create: jest.fn(),
    save: jest.fn(),
    findOne: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MoodsService,
        {
          provide: getRepositoryToken(Mood),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<MoodsService>(MoodsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create and save a mood', async () => {
      const moodData = { label: 'Happy', emoji: '😊' };
      const userId = 1;
      mockRepository.create.mockReturnValue({ userId, ...moodData });
      mockRepository.save.mockResolvedValue({ id: 1, userId, ...moodData });

      const result = await service.create(userId, moodData);
      expect(result).toEqual({ id: 1, userId, ...moodData });
      expect(mockRepository.create).toHaveBeenCalledWith({ userId, ...moodData });
    });
  });

  describe('findLatestByUser', () => {
    it('should find the latest mood for a user', async () => {
      const userId = 1;
      const mood = { id: 1, userId, label: 'Happy', emoji: '😊' };
      mockRepository.findOne.mockResolvedValue(mood);

      const result = await service.findLatestByUser(userId);
      expect(result).toEqual(mood);
      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { userId },
        order: { createdAt: 'DESC' },
      });
    });
  });
});
