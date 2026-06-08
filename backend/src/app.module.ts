import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { ActivityLogsModule } from './activity-logs/activity-logs.module';
import { MoodsModule } from './moods/moods.module';
import { ForumModule } from './forum/forum.module';
import { JournalsModule } from './journals/journals.module';
import { HabitsModule } from './habits/habits.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ServeStaticModule.forRoot({
      rootPath: join(process.cwd(), 'uploads'),
      serveRoot: '/uploads',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('DATABASE_HOST'),
        port: configService.get<number>('DATABASE_PORT'),
        username: configService.get<string>('DATABASE_USER'),
        password: configService.get<string>('DATABASE_PASSWORD'),
        database: configService.get<string>('DATABASE_NAME'),
        autoLoadEntities: true,
        synchronize: true, // Sebaiknya dimatikan di produksi
      }),
    }),
    UsersModule,
    AuthModule,
    ActivityLogsModule,
    MoodsModule,
    ForumModule,
    JournalsModule,
    HabitsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
