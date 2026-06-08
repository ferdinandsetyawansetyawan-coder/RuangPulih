import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  Unique,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { ForumPost } from './forum.entity';

@Entity('forum_saved_posts')
@Unique(['userId', 'postId'])
export class ForumSavedPost {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  userId: number;

  @ManyToOne(() => ForumPost)
  @JoinColumn({ name: 'postId' })
  post: ForumPost;

  @Column()
  postId: number;

  @CreateDateColumn()
  savedAt: Date;
}
