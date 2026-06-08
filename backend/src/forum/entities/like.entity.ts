import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { ForumPost } from './forum.entity';

@Entity('forum_likes')
@Unique(['userId', 'postId'])
export class ForumLike {
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
}
