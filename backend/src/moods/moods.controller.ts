import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { MoodsService } from './moods.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('moods')
@UseGuards(JwtAuthGuard)
export class MoodsController {
  constructor(private readonly moodsService: MoodsService) {}

  @Post()
  async create(@Body() body: { userId: number; label: string; emoji: string }) {
    return this.moodsService.create(body.userId, {
      label: body.label,
      emoji: body.emoji,
    });
  }

  @Get('latest/:userId')
  async findLatest(@Param('userId') userId: string) {
    return this.moodsService.findLatestByUser(+userId);
  }

  @Get('user/:userId')
  async findAllByUser(@Param('userId') userId: string) {
    return this.moodsService.findAllByUser(+userId);
  }
}
