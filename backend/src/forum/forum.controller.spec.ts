import { Test, TestingModule } from '@nestjs/testing';
import { ForumController } from './forum.controller';
import { ForumService } from './forum.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ExecutionContext } from '@nestjs/common';

describe('ForumController', () => {
  let controller: ForumController;
  let mockForumService = {
    create: jest.fn(),
    findAll: jest.fn(),
    toggleLike: jest.fn(),
    toggleSave: jest.fn(),
    getComments: jest.fn(),
    addComment: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ForumController],
      providers: [
        {
          provide: ForumService,
          useValue: mockForumService,
        },
      ],
    })
    .overrideGuard(JwtAuthGuard)
    .useValue({ canActivate: (context: ExecutionContext) => true })
    .compile();

    controller = module.get<ForumController>(ForumController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('create', () => {
    it('should call forumService.create', async () => {
      const body = { userId: 1, category: 'General', content: 'Hello' };
      await controller.create(body);
      expect(mockForumService.create).toHaveBeenCalledWith(1, {
        category: 'General',
        content: 'Hello',
        isAnonymous: false,
      });
    });
  });

  describe('findAll', () => {
    it('should call forumService.findAll', async () => {
      await controller.findAll('General', 'public', '1');
      expect(mockForumService.findAll).toHaveBeenCalledWith(1, 'General', 'public');
    });
  });

  describe('toggleLike', () => {
    it('should call forumService.toggleLike', async () => {
      await controller.toggleLike('1', 1);
      expect(mockForumService.toggleLike).toHaveBeenCalledWith(1, 1);
    });
  });

  describe('getComments', () => {
    it('should call forumService.getComments', async () => {
      await controller.getComments('1');
      expect(mockForumService.getComments).toHaveBeenCalledWith(1);
    });
  });

  describe('addComment', () => {
    it('should call forumService.addComment', async () => {
      await controller.addComment('1', 1, 'Nice!');
      expect(mockForumService.addComment).toHaveBeenCalledWith(1, 1, 'Nice!');
    });
  });
});
