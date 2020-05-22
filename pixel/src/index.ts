import '@/env';

import { CallHandler, ExecutionContext, Injectable, Module, NestInterceptor, UseInterceptors } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { TerminusModule } from '@nestjs/terminus';
import { TypeOrmModule } from '@nestjs/typeorm';
import { config, PageView, Project, ProjectEvent, Team, User } from '@thesemetrics/database';
import { FastifyRequest } from 'fastify';
import { HealthController } from '@/HealthController';
import { PixelController } from '@/PixelController';
import { PixelService } from '@/PixelService';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler) {
    const request = context.switchToHttp().getRequest<FastifyRequest>();
    console.log(`${request.req.url}`, request.query);

    return next.handle();
  }
}

@UseInterceptors(new LoggingInterceptor())
@Module({
  imports: [
    TerminusModule,
    TypeOrmModule.forRoot({
      ...config(),
      entities: [User, Team, Project, ProjectEvent, PageView],
      synchronize: false,
    }),
    TypeOrmModule.forFeature([User, Team, Project, ProjectEvent, PageView]),
  ],
  providers: [PixelService],
  controllers: [PixelController, HealthController],
})
class AppModule {}

async function bootstrap() {
  const app = await NestFactory.create<NestFastifyApplication>(AppModule, new FastifyAdapter());
  app.enableCors();

  return app.listen(3001, '0.0.0.0', (error, address) => {
    if (error) console.error(error);
    else console.log(`pixel@0.1.5 listening at ${address}`);
  });
}

bootstrap().catch((error) => {
  console.error(error);
  process.exit(1);
});
