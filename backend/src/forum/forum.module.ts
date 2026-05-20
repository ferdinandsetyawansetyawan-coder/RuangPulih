import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ForumController } from './forum.controller';
import { ForumService } from './forum.service';
import { ForumPost } from './entities/forum.entity';
import { ForumComment } from './entities/comment.entity';
import { ForumLike } from './entities/like.entity';
import { ForumSavedPost } from './entities/saved-post.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ForumPost, ForumComment, ForumLike, ForumSavedPost])],
  controllers: [ForumController],
  providers: [ForumService],
  exports: [ForumService],
})
export class ForumModule {}
