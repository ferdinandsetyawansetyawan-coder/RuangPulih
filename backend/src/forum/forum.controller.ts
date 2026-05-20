import { Controller, Get, Post, Body, Param, UseGuards, Query } from '@nestjs/common';
import { ForumService } from './forum.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('forum')
@UseGuards(JwtAuthGuard)
export class ForumController {
  constructor(private readonly forumService: ForumService) {}

  @Post()
  async create(@Body() body: { userId: number; category: string; content: string; isAnonymous?: boolean }) {
    console.log('Received create post request:', body);
    try {
      const result = await this.forumService.create(body.userId, {
        category: body.category,
        content: body.content,
        isAnonymous: body.isAnonymous ?? false,
      });
      console.log('Post created successfully:', result.id);
      return result;
    } catch (error) {
      console.error('Error creating post in controller:', error);
      throw error;
    }
  }

  @Get()
  async findAll(
    @Query('category') category?: string,
    @Query('type') type?: string,
    @Query('userId') userId?: string,
  ) {
    return this.forumService.findAll(userId ? +userId : undefined, category, type);
  }

  @Post(':id/like')
  async toggleLike(@Param('id') id: string, @Body('userId') userId: number) {
    return this.forumService.toggleLike(userId, +id);
  }

  @Post(':id/save')
  async toggleSave(@Param('id') id: string, @Body('userId') userId: number) {
    return this.forumService.toggleSave(userId, +id);
  }

  @Get(':id/comments')
  async getComments(@Param('id') id: string) {
    return this.forumService.getComments(+id);
  }

  @Post(':id/comments')
  async addComment(
    @Param('id') id: string,
    @Body('userId') userId: number,
    @Body('content') content: string,
  ) {
    return this.forumService.addComment(userId, +id, content);
  }
}
