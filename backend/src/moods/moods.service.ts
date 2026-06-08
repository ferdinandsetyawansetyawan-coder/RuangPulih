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
    // Cek apakah sudah ada mood hari ini
    const latestMood = await this.findLatestByUser(userId);
    if (latestMood) {
      // Jika sudah ada mood hari ini, tidak usah buat baru (return yang sudah ada)
      return latestMood;
    }

    const mood = this.moodsRepository.create({
      userId,
      ...moodData,
    });
    return this.moodsRepository.save(mood);
  }

  async findLatestByUser(userId: number) {
    const latestMood = await this.moodsRepository.findOne({
      where: { userId },
      order: { createdAt: 'DESC' },
    });

    if (!latestMood) return null;

    // Gunakan perbandingan string YYYY-MM-DD agar aman dari masalah timezone jam/menit
    const todayStr = new Date().toISOString().split('T')[0];
    const moodDateStr = new Date(latestMood.createdAt).toISOString().split('T')[0];
    
    if (todayStr === moodDateStr) {
      return latestMood;
    }

    return null; 
  }

  async findAllByUser(userId: number) {
    return this.moodsRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }
}
