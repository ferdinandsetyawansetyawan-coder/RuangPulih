import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { AiService } from './ai.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @UseGuards(JwtAuthGuard)
  @Post('chat')
  async chat(@Body('message') message: string) {
    console.log(`[AiController] POST /ai/chat dipanggil. Payload message: "${message}"`);
    const response = await this.aiService.generateResponse(message);
    return {
      reply: response,
      timestamp: new Date().toISOString(),
    };
  }

  @Post('journal-insight')
  async journalInsight(
    @Body('title') title: string,
    @Body('content') content: string,
  ) {
    console.log(`[AiController] POST /ai/journal-insight for: "${title}"`);
    const insight = await this.aiService.generateJournalInsight(title, content);
    return { insight };
  }
}
