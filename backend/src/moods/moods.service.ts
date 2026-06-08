import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Mood } from './entities/mood.entity';

@Injectable()
export class MoodsService {
  constructor(
    @InjectRepository(Mood)
    private moodsRepository: Repository<Mood>,
  ) {}

  async create(userId: number, moodData: { label: string; emoji: string }) {
    const mood = this.moodsRepository.create({
      userId,
      ...moodData,
    });
    return this.moodsRepository.save(mood);
  }

  async findLatestByUser(userId: number) {
    return this.moodsRepository.findOne({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async findAllByUser(userId: number) {
    return this.moodsRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }
}
