import { Test, TestingModule } from '@nestjs/testing';
import { JournalsService } from './journals.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Journal } from './entities/journal.entity';

describe('JournalsService', () => {
  let service: JournalsService;
  let mockRepository = {
    create: jest.fn(),
    save: jest.fn(),
    find: jest.fn(),
    findOne: jest.fn(),
    delete: jest.fn(),
    update: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        JournalsService,
        {
          provide: getRepositoryToken(Journal),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<JournalsService>(JournalsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create and save a journal entry', async () => {
      const data = { title: 'My Day', content: 'It was good.' };
      const userId = 1;
      mockRepository.create.mockReturnValue({ userId, ...data });
      mockRepository.save.mockResolvedValue({ id: 1, userId, ...data });

      const result = await service.create(userId, data);
      expect(result).toEqual({ id: 1, userId, ...data });
    });
  });

  describe('findAllByUser', () => {
    it('should find all journals for a user', async () => {
      const userId = 1;
      const journals = [{ id: 1, userId, title: 'Title' }];
      mockRepository.find.mockResolvedValue(journals);

      const result = await service.findAllByUser(userId);
      expect(result).toEqual(journals);
    });
  });

  describe('findOne', () => {
    it('should find one journal for a user', async () => {
      const id = 1;
      const userId = 1;
      const journal = { id, userId, title: 'Title' };
      mockRepository.findOne.mockResolvedValue(journal);

      const result = await service.findOne(id, userId);
      expect(result).toEqual(journal);
    });
  });

  describe('remove', () => {
    it('should delete a journal for a user', async () => {
      const id = 1;
      const userId = 1;
      mockRepository.delete.mockResolvedValue({ affected: 1 });

      const result = await service.remove(id, userId);
      expect(result).toEqual({ affected: 1 });
    });
  });

  describe('update', () => {
    it('should update a journal and return the updated version', async () => {
      const id = 1;
      const userId = 1;
      const data = { title: 'Updated' };
      const updatedJournal = { id, userId, title: 'Updated' };
      
      mockRepository.update.mockResolvedValue({ affected: 1 });
      mockRepository.findOne.mockResolvedValue(updatedJournal);

      const result = await service.update(id, userId, data);
      expect(result).toEqual(updatedJournal);
      expect(mockRepository.update).toHaveBeenCalledWith({ id, userId }, data);
    });
  });
});
