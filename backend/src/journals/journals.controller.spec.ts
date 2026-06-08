import { Test, TestingModule } from '@nestjs/testing';
import { JournalsController } from './journals.controller';
import { JournalsService } from './journals.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ExecutionContext } from '@nestjs/common';

describe('JournalsController', () => {
  let controller: JournalsController;
  const mockJournalsService = {
    create: jest.fn(),
    update: jest.fn(),
    findAllByUser: jest.fn(),
    remove: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [JournalsController],
      providers: [
        {
          provide: JournalsService,
          useValue: mockJournalsService,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({ canActivate: (context: ExecutionContext) => true })
      .compile();

    controller = module.get<JournalsController>(JournalsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('create', () => {
    it('should call journalsService.create', async () => {
      const body = { userId: 1, title: 'Title' };
      await controller.create(body);
      expect(mockJournalsService.create).toHaveBeenCalledWith(1, body);
    });
  });

  describe('update', () => {
    it('should call journalsService.update', async () => {
      const body = { userId: 1, title: 'Updated' };
      await controller.update('1', body);
      expect(mockJournalsService.update).toHaveBeenCalledWith(1, 1, body);
    });
  });

  describe('findAll', () => {
    it('should call journalsService.findAllByUser', async () => {
      await controller.findAll('1');
      expect(mockJournalsService.findAllByUser).toHaveBeenCalledWith(1);
    });
  });

  describe('remove', () => {
    it('should call journalsService.remove', async () => {
      await controller.remove('1', '1');
      expect(mockJournalsService.remove).toHaveBeenCalledWith(1, 1);
    });
  });
});
