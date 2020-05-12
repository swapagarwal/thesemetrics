import './env'

import { NestFactory } from '@nestjs/core'
import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { Project, ProjectEvent, User, Team } from '@thesemetrics/database'
import { PixelController } from './PixelController'
import { ProjectService } from './ProjectService'
import {
  FastifyAdapter,
  NestFastifyApplication,
} from '@nestjs/platform-fastify'

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.POSTGRES_URL,
      entities: [User, Team, Project, ProjectEvent],
      synchronize: false,
    }),
    TypeOrmModule.forFeature([Team, Project, ProjectEvent]),
  ],
  providers: [ProjectService],
  controllers: [PixelController],
})
class AppModule {}

async function bootstrap() {
  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter({
      cors: true,
    })
  )

  app.listen(3001)
}

bootstrap()
