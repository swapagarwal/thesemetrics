import './env';

import { CallHandler, ExecutionContext, Injectable, Module, NestInterceptor, UseInterceptors } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PageView, Project, ProjectEvent, Team, User } from '@thesemetrics/database';
import { PixelController } from './PixelController';
import { ProjectService } from './ProjectService';


@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler) {
    console.log(`${context.getType()}`, context.switchToHttp().getRequest());

    return next.handle();
  }
}

@UseInterceptors(new LoggingInterceptor())
@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.POSTGRES_URL,
      entities: [User, Team, Project, ProjectEvent, PageView],
      synchronize: false,
    }),
    TypeOrmModule.forFeature([User, Team, Project, ProjectEvent, PageView]),
  ],
  providers: [ProjectService],
  controllers: [PixelController],
})
class AppModule {}

async function bootstrap() {
  const app = await NestFactory.create<NestFastifyApplication>(AppModule, new FastifyAdapter());

  app.enableCors();
  app.listen(3001);
}

bootstrap();
