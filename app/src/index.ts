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

  app.enableCors();
  return app.listen(3000, '0.0.0.0', (error, address) => {
    if (error) console.error(error);
    else console.log(`app@0.1.5 listening at ${address}`);
  });
}

bootstrap().catch((error) => {
  console.error(error);
  process.exit(1);
});
