import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ForumPost } from './entities/forum.entity';
import { ForumComment } from './entities/comment.entity';
import { ForumLike } from './entities/like.entity';
import { ForumSavedPost } from './entities/saved-post.entity';

@Injectable()
export class ForumService {
  constructor(
    @InjectRepository(ForumPost)
    private forumRepository: Repository<ForumPost>,
    @InjectRepository(ForumComment)
    private commentRepository: Repository<ForumComment>,
    @InjectRepository(ForumLike)
    private likeRepository: Repository<ForumLike>,
    @InjectRepository(ForumSavedPost)
    private savedPostRepository: Repository<ForumSavedPost>,
  ) {}

  async create(userId: number, data: { category: string; content: string; isAnonymous?: boolean }) {
    console.log('ForumService.create - userId:', userId, 'data:', data);
    const post = this.forumRepository.create({
      userId,
      ...data,
    });
    console.log('Created post entity:', post);
    return this.forumRepository.save(post);
  }

  async findAll(userId?: number, category?: string, type?: string) {
    const query = this.forumRepository.createQueryBuilder('post')
      .leftJoinAndSelect('post.user', 'user')
      .loadRelationCountAndMap('post.likes', 'post.likesList')
      .loadRelationCountAndMap('post.comments', 'post.commentsList')
      .orderBy('post.createdAt', 'DESC');

    if (category && category !== 'Semua' && category !== 'Tersimpan') {
      query.andWhere('post.category = :category', { category });
    }

    if (type === 'public') {
      query.andWhere('post.isAnonymous = false');
    } else if (type === 'anonymous') {
      query.andWhere('post.isAnonymous = true');
    }

    if (category === 'Tersimpan' && userId) {
      query.innerJoin('post.savedBy', 'saved', 'saved.userId = :userId', { userId });
    }

    const posts = await query.getMany();

    // Map counts to numbers and set isLiked/isSaved efficiently
    let likedPostIds: number[] = [];
    let savedPostIds: number[] = [];

    if (userId) {
      const likes = await this.likeRepository.find({
        where: { userId },
        select: ['postId'],
      });
      likedPostIds = likes.map((l) => l.postId);

      const saves = await this.savedPostRepository.find({
        where: { userId },
        select: ['postId'],
      });
      savedPostIds = saves.map((s) => s.postId);
    }

    return posts.map((post) => {
      const p = { ...post } as any;
      p.likes = Number((post as any).likes || 0);
      p.comments = Number((post as any).comments || 0);
      p.isLiked = likedPostIds.includes(post.id);
      p.isSaved = savedPostIds.includes(post.id);
      return p;
    });
  }

  async toggleLike(userId: number, postId: number) {
    const existing = await this.likeRepository.findOne({ where: { userId, postId } });
    if (existing) {
      await this.likeRepository.remove(existing);
      return { liked: false };
    } else {
      const like = this.likeRepository.create({ userId, postId });
      await this.likeRepository.save(like);
      return { liked: true };
    }
  }

  async toggleSave(userId: number, postId: number) {
    const existing = await this.savedPostRepository.findOne({ where: { userId, postId } });
    if (existing) {
      await this.savedPostRepository.remove(existing);
      return { saved: false };
    } else {
      const saved = this.savedPostRepository.create({ userId, postId });
      await this.savedPostRepository.save(saved);
      return { saved: true };
    }
  }

  async addComment(userId: number, postId: number, content: string) {
    const comment = this.commentRepository.create({ userId, postId, content });
    return this.commentRepository.save(comment);
  }

  async getComments(postId: number) {
    return this.commentRepository.find({
      where: { postId },
      relations: ['user'],
      order: { createdAt: 'ASC' },
    });
  }
}
