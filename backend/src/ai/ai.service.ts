import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenerativeAI, GenerativeModel } from '@google/generative-ai';

@Injectable()
export class AiService implements OnModuleInit {
  private genAI: GoogleGenerativeAI;
  private model: GenerativeModel;

  constructor(private configService: ConfigService) {}

  onModuleInit() {
    const apiKey = this.configService.get<string>('GEMINI_API_KEY') || '';
    this.genAI = new GoogleGenerativeAI(apiKey);
    this.model = this.genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
      systemInstruction: `Kamu adalah Pulih, asisten kesehatan mental yang empatik dan penuh perhatian dari RuangPulih.

Peranmu adalah:
- Mendengarkan dengan penuh empati tanpa menghakimi
- Memberikan dukungan emosional yang hangat dan tulus
- Membantu pengguna memahami dan mengelola perasaan mereka
- Menggunakan bahasa Indonesia yang santai, hangat, dan mudah dipahami
- Memberikan saran praktis berbasis mindfulness dan kesehatan mental
- Selalu mengingatkan bahwa kamu bukan pengganti profesional kesehatan mental

Gaya bicara: hangat, sabar, tidak menggurui. Seperti teman yang baik yang mendengarkan.`,
    });
  }

  async generateResponse(prompt: string): Promise<string> {
    console.log(`[AiService] Menerima prompt dari user: "${prompt}"`);
    try {
      const systemPrompt = `Kamu adalah Pulih, asisten kesehatan mental yang empatik dan penuh perhatian dari RuangPulih.
Peranmu adalah:
- Mendengarkan dengan penuh empati tanpa menghakimi
- Memberikan dukungan emosional yang hangat dan tulus
- Menggunakan bahasa Indonesia yang santai, hangat, dan mudah dipahami
- Selalu mengingatkan bahwa kamu bukan pengganti profesional kesehatan mental
Gaya bicara: hangat, sabar, tidak menggurui. Seperti teman yang baik yang mendengarkan.`;

      console.log(`[AiService] Mengirim request ke Gemini (model: gemini-2.5-flash)...`);
      const result = await this.model.generateContent([
        { text: systemPrompt },
        { text: prompt }
      ]);
      const response = await result.response;
      const textResponse = response.text();
      console.log(`[AiService] Berhasil mendapat balasan dari Gemini: "${textResponse.substring(0, 50)}..."`);
      return textResponse;
    } catch (error: any) {
      console.error('[AiService] Gemini AI Error Details:');
      console.error('- Message:', error.message);
      console.error('- Stack:', error.stack);
      return 'Maaf, sepertinya Pulih sedang sedikit lelah. Bisa ceritakan lagi nanti?';
    }
  }

  async generateJournalInsight(title: string, content: string): Promise<string> {
    console.log(`[AiService] Generating journal insight for: "${title}"`);
    try {
      const systemPrompt = `Kamu adalah Pulih, asisten kesehatan mental yang empatik dari RuangPulih.
Tugas kamu: baca jurnal harian seseorang dan berikan respons singkat (2-4 kalimat) dalam bahasa Indonesia yang:
1. Menunjukkan kamu memahami apa yang mereka rasakan/alami
2. Memberikan satu saran praktis atau sudut pandang baru yang relevan
3. Mengakhiri dengan kalimat penyemangat yang hangat dan tulus
Jangan pakai bullet point. Tulis seperti pesan dari teman yang peduli. Jangan terlalu panjang.`;

      const userPrompt = `Ini jurnal harianku hari ini:\nJudul: "${title}"\nIsi: "${content}"`;

      const result = await this.model.generateContent([
        { text: systemPrompt },
        { text: userPrompt },
      ]);
      const response = await result.response;
      const text = response.text();
      console.log(`[AiService] Journal insight generated: "${text.substring(0, 80)}..."`);
      return text.trim();
    } catch (error: any) {
      console.error('[AiService] Journal insight error:', error.message);
      return 'Terima kasih sudah mau berbagi hari ini. Apapun yang kamu rasakan, itu valid. Kamu sudah melangkah dengan baik hanya dengan menuliskannya. 💙';
    }
  }
}
