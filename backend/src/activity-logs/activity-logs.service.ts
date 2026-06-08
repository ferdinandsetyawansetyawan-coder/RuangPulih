import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ActivityLog } from './entities/activity-log.entity';

@Injectable()
export class ActivityLogsService {
  constructor(
    @InjectRepository(ActivityLog)
    private logsRepository: Repository<ActivityLog>,
  ) {}

  async log(
    userId: number | null,
    action: string,
    description?: string,
    ipAddress?: string,
  ) {
    const logEntry = this.logsRepository.create({
      userId,
      action,
      description,
      ipAddress,
    });
    return this.logsRepository.save(logEntry);
  }

  async findAll() {
    return this.logsRepository.find({
      order: { createdAt: 'DESC' },
      take: 100, // Ambil 100 log terbaru saja biar ringan
    });
  }
}
