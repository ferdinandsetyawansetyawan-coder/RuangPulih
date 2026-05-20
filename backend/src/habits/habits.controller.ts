import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Query } from '@nestjs/common';
import { HabitsService } from './habits.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('habits')
@UseGuards(JwtAuthGuard)
export class HabitsController {
  constructor(private readonly habitsService: HabitsService) {}

  @Get()
  async findAll(@Query('userId') userId: string) {
    return this.habitsService.findAll(+userId);
  }

  @Post()
  async create(@Body() body: { userId: number; title: string; subtitle?: string; emoji: string }) {
    return this.habitsService.create(body.userId, {
      title: body.title,
      subtitle: body.subtitle,
      emoji: body.emoji,
    });
  }

  @Put(':id')
  async update(
    @Param('id') id: string,
    @Body() body: { userId: number; title: string; subtitle?: string; emoji: string },
  ) {
    return this.habitsService.update(body.userId, +id, {
      title: body.title,
      subtitle: body.subtitle,
      emoji: body.emoji,
    });
  }

  @Delete(':id/:userId')
  async remove(@Param('id') id: string, @Param('userId') userId: string) {
    return this.habitsService.remove(+userId, +id);
  }

  @Post(':id/toggle')
  async toggle(@Param('id') id: string, @Body('userId') userId: number) {
    return this.habitsService.toggleCompletion(userId, +id);
  }
}
