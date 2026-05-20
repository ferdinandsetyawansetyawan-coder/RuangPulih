import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, OneToMany } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { ForumLike } from './like.entity';
import { ForumComment } from './comment.entity';
import { ForumSavedPost } from './saved-post.entity';

@Entity('forum_posts')
export class ForumPost {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  category: string;

  @Column('text')
  content: string;

  @Column({ default: false })
  isAnonymous: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => User, (user) => user.id)
  user: User;

  @Column()
  userId: number;

  @OneToMany(() => ForumLike, (like) => like.post)
  likesList: ForumLike[];

  @OneToMany(() => ForumComment, (comment) => comment.post)
  commentsList: ForumComment[];

  @OneToMany(() => ForumSavedPost, (saved) => saved.post)
  savedBy: ForumSavedPost[];
}
