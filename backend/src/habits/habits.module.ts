import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HabitsService } from './habits.service';
import { HabitsController } from './habits.controller';
import { Habit } from './entities/habit.entity';
import { HabitCompletion } from './entities/habit-completion.entity';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [TypeOrmModule.forFeature([Habit, HabitCompletion]), UsersModule],
  providers: [HabitsService],
  controllers: [HabitsController],
  exports: [HabitsService],
})
export class HabitsModule {}
