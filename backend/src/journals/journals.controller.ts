import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  UseGuards,
  Put,
} from '@nestjs/common';
import { JournalsService } from './journals.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('journals')
@UseGuards(JwtAuthGuard)
export class JournalsController {
  constructor(private readonly journalsService: JournalsService) {}

  @Post()
  async create(@Body() body: any) {
    return this.journalsService.create(body.userId, body);
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() body: any) {
    return this.journalsService.update(+id, body.userId, body);
  }

  @Get('user/:userId')
  async findAll(@Param('userId') userId: string) {
    return this.journalsService.findAllByUser(+userId);
  }

  @Delete(':id/:userId')
  async remove(@Param('id') id: string, @Param('userId') userId: string) {
    return this.journalsService.remove(+id, +userId);
  }
}
