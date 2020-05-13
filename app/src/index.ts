import './env'

import { NestFactory } from '@nestjs/core'
import { Module } from '@nestjs/common'
import {
  FastifyAdapter,
  NestFastifyApplication,
} from '@nestjs/platform-fastify'

@Module({})
class AppModule {}

async function bootstrap() {
  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter({
      cors: true,
    })
  )

  app.listen(3000)
}

bootstrap()
