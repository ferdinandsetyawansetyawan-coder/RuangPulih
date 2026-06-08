import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenerativeAI, GenerativeModel } from '@google/generative-ai';

@Injectable()
export class GeminiService implements OnModuleInit {
  private genAI: GoogleGenerativeAI;
  private model: GenerativeModel;

  constructor(private configService: ConfigService) {}

  onModuleInit() {
    const apiKey = this.configService.get<string>('GEMINI_API_KEY');
    if (!apiKey) {
      console.error('[GeminiService] API Key missing!');
      return;
    }
    this.genAI = new GoogleGenerativeAI(apiKey);
    this.model = this.genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
    console.log('[GeminiService] AI Model initialized');
  }

  async generateFeedback(content: string): Promise<string> {
    if (!this.model) {
      console.error('[GeminiService] Model not initialized, check API Key');
      return 'Tetap semangat, setiap langkah kecil sangat berarti. 💙';
    }

    const prompt = `
      Kamu adalah seorang psikolog empati. Tugasmu adalah menjadi "Detektif Titik Terang" (Silver Lining Extractor).
      Baca teks jurnal harian berikut. Sekalipun teks tersebut sangat sedih, marah, atau negatif, temukan SATU hal positif, "kemenangan kecil", atau kekuatan mental yang ditunjukkan oleh penulis.
      Berikan respon berupa 1-2 kalimat singkat yang mengapresiasi kekuatan atau titik terang tersebut dalam Bahasa Indonesia.
      Gunakan bahasa yang hangat dan tidak menggurui. Jangan gunakan format tambahan, langsung berikan kalimatnya.

      Teks Jurnal: "${content}"
    `;

    try {
      console.log(`[GeminiService] Generating feedback for: "${content.substring(0, 30)}..."`);
      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      const text = response.text().trim();
      console.log(`[GeminiService] AI Raw Response: "${text}"`);
      
      return text || 'Tetap semangat, setiap langkah kecil sangat berarti. 💙';
    } catch (error) {
      console.error('[GeminiService] Error during feedback generation:', error.message);
      return 'Tetap semangat, setiap langkah kecil sangat berarti. 💙';
    }
  }
}
