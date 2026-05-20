import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Journal } from './entities/journal.entity';

@Injectable()
export class JournalsService {
  constructor(
    @InjectRepository(Journal)
    private journalsRepository: Repository<Journal>,
  ) {}

  async create(userId: number, data: any) {
    const journal = this.journalsRepository.create({
      userId,
      ...data,
    });
    return this.journalsRepository.save(journal);
  }

  async findAllByUser(userId: number) {
    return this.journalsRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number, userId: number) {
    return this.journalsRepository.findOne({
      where: { id, userId },
    });
  }

  async remove(id: number, userId: number) {
    return this.journalsRepository.delete({ id, userId });
  }

  async update(id: number, userId: number, data: any) {
    await this.journalsRepository.update({ id, userId }, data);
    return this.findOne(id, userId);
  }
}
