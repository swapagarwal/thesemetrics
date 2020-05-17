import '@/env';

import { NestFactory } from '@nestjs/core';
import { Module } from '@nestjs/common';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import StatsModule from '@/modules/stats';

@Module({
  imports: [StatsModule],
})
class AppModule {}

async function bootstrap() {
  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter({
      cors: true,
    })
  );

  app.enableCors()

  app.listen(3000);
}

bootstrap();
