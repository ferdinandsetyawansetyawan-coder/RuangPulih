import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
} from 'typeorm';
import { Habit } from './habit.entity';

@Entity('habit_completions')
export class HabitCompletion {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  habitId: number;

  @ManyToOne(() => Habit, (habit) => habit.completions, { onDelete: 'CASCADE' })
  habit: Habit;

  @Column({ type: 'date' })
  date: string; // YYYY-MM-DD

  @CreateDateColumn()
  createdAt: Date;
}
