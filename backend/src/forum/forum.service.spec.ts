import { Test, TestingModule } from '@nestjs/testing';
import { ForumService } from './forum.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ForumPost } from './entities/forum.entity';
import { ForumComment } from './entities/comment.entity';
import { ForumLike } from './entities/like.entity';
import { ForumSavedPost } from './entities/saved-post.entity';

describe('ForumService', () => {
  let service: ForumService;

  const mockForumRepository = {
    create: jest.fn(),
    save: jest.fn(),
    createQueryBuilder: jest.fn(),
  };
  const mockCommentRepository = {
    create: jest.fn(),
    save: jest.fn(),
    find: jest.fn(),
  };
  const mockLikeRepository = {
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    remove: jest.fn(),
  };
  const mockSavedPostRepository = {
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    remove: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ForumService,
        {
          provide: getRepositoryToken(ForumPost),
          useValue: mockForumRepository,
        },
        {
          provide: getRepositoryToken(ForumComment),
          useValue: mockCommentRepository,
        },
        {
          provide: getRepositoryToken(ForumLike),
          useValue: mockLikeRepository,
        },
        {
          provide: getRepositoryToken(ForumSavedPost),
          useValue: mockSavedPostRepository,
        },
      ],
    }).compile();

    service = module.get<ForumService>(ForumService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create and save a forum post', async () => {
      const data = { category: 'General', content: 'Hello' };
      const userId = 1;
      mockForumRepository.create.mockReturnValue({ userId, ...data });
      mockForumRepository.save.mockResolvedValue({ id: 1, userId, ...data });

      const result = await service.create(userId, data);
      expect(result).toEqual({ id: 1, userId, ...data });
    });
  });

  describe('toggleLike', () => {
    it('should remove like if it exists', async () => {
      const existing = { id: 1, userId: 1, postId: 1 };
      mockLikeRepository.findOne.mockResolvedValue(existing);

      const result = await service.toggleLike(1, 1);
      expect(result).toEqual({ liked: false });
      expect(mockLikeRepository.remove).toHaveBeenCalledWith(existing);
    });

    it('should add like if it does not exist', async () => {
      mockLikeRepository.findOne.mockResolvedValue(null);
      mockLikeRepository.create.mockReturnValue({ userId: 1, postId: 1 });

      const result = await service.toggleLike(1, 1);
      expect(result).toEqual({ liked: true });
      expect(mockLikeRepository.save).toHaveBeenCalled();
    });
  });

  describe('addComment', () => {
    it('should create and save a comment', async () => {
      const data = { content: 'Nice!' };
      mockCommentRepository.create.mockReturnValue({
        userId: 1,
        postId: 1,
        ...data,
      });
      mockCommentRepository.save.mockResolvedValue({
        id: 1,
        userId: 1,
        postId: 1,
        ...data,
      });

      const result = await service.addComment(1, 1, 'Nice!');
      expect(result).toEqual({ id: 1, userId: 1, postId: 1, ...data });
    });
  });
});
