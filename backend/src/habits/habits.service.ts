import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Habit } from './entities/habit.entity';
import { HabitCompletion } from './entities/habit-completion.entity';
import { UsersService } from '../users/users.service';

@Injectable()
export class HabitsService {
  constructor(
    @InjectRepository(Habit)
    private habitsRepository: Repository<Habit>,
    @InjectRepository(HabitCompletion)
    private completionsRepository: Repository<HabitCompletion>,
    private usersService: UsersService,
  ) {}

  async findAll(userId: number): Promise<any[]> {
    const habits = await this.habitsRepository.find({
      where: { userId },
      relations: ['completions'],
    });

    const todayDate = new Date();
    const today = todayDate.toISOString().split('T')[0];

    const yesterdayDate = new Date();
    yesterdayDate.setDate(yesterdayDate.getDate() - 1);
    const yesterday = yesterdayDate.toISOString().split('T')[0];

    // Get last 7 days labels
    const last7Days: string[] = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      last7Days.push(d.toISOString().split('T')[0]);
    }

    return Promise.all(
      habits.map(async (h) => {
        const completionDates = h.completions.map((c) => c.date);
        const completedToday = completionDates.includes(today);
        const completedYesterday = completionDates.includes(yesterday);

        // If missed today AND yesterday, streak is broken
        if (!completedToday && !completedYesterday && h.streakDays > 0) {
          h.streakDays = 0;
          await this.habitsRepository.update(h.id, { streakDays: 0 });
        }

        return {
          ...h,
          completedToday,
          weekHistory: last7Days.map((date) => completionDates.includes(date)),
        };
      }),
    );
  }

  async create(userId: number, habitData: Partial<Habit>): Promise<Habit> {
    const habit = this.habitsRepository.create({ ...habitData, userId });
    const savedHabit = await this.habitsRepository.save(habit);
    await this.usersService.addExp(userId, 50); // XP for creating a habit
    return savedHabit;
  }

  async update(
    userId: number,
    id: number,
    habitData: Partial<Habit>,
  ): Promise<Habit | null> {
    await this.habitsRepository.update({ id, userId }, habitData);
    return this.habitsRepository.findOneBy({ id, userId });
  }

  async remove(userId: number, id: number): Promise<void> {
    await this.habitsRepository.delete({ id, userId });
  }

  async toggleCompletion(userId: number, id: number): Promise<any> {
    const habit = await this.habitsRepository.findOneBy({ id, userId });
    if (!habit) throw new Error('Habit not found');

    const todayDate = new Date();
    const today = todayDate.toISOString().split('T')[0];

    const yesterdayDate = new Date();
    yesterdayDate.setDate(yesterdayDate.getDate() - 1);
    const yesterday = yesterdayDate.toISOString().split('T')[0];

    const completion = await this.completionsRepository.findOneBy({
      habitId: id,
      date: today,
    });

    let completedToday = false;
    if (completion) {
      // Habit is already completed today, prevent untoggling (uncheck).
      // Just return the current state.
      const user = await this.usersService.findOne(userId);
      return {
        completedToday: true,
        streakDays: habit.streakDays,
        exp: user?.exp ?? 0,
        level: user?.level ?? 1,
      };
    } else {
      // Toggling completion (checking)
      const newCompletion = this.completionsRepository.create({
        habitId: id,
        date: today,
      });
      await this.completionsRepository.save(newCompletion);
      await this.usersService.addExp(userId, 15);
      completedToday = true;

      const completedYesterday = await this.completionsRepository.findOneBy({
        habitId: id,
        date: yesterday,
      });
      if (completedYesterday) {
        habit.streakDays++;
      } else {
        habit.streakDays = 1; // Start new streak
      }
    }

    await this.habitsRepository.save(habit);

    const user = await this.usersService.findOne(userId);
    if (!user) throw new Error('User not found');

    return {
      completedToday,
      streakDays: habit.streakDays,
      exp: user.exp,
      level: user.level,
    };
  }
}
