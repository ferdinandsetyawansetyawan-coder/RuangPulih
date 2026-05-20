import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JournalsController } from './journals.controller';
import { JournalsService } from './journals.service';
import { Journal } from './entities/journal.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Journal])],
  controllers: [JournalsController],
  providers: [JournalsService],
})
export class JournalsModule {}
