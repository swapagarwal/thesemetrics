import {
  Controller,
  Get,
  Headers,
  Query,
  Res,
  BadRequestException,
} from '@nestjs/common'
import { lookup } from 'useragent'
import { ProjectService } from './ProjectService'
import { FastifyReply } from 'fastify'

const pixel = Buffer.from(
  'R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=',
  'base64'
)

@Controller()
export class PixelController {
  constructor(private readonly service: ProjectService) {}

  @Get('/default.gif')
  public async getDefaultPixel(
    @Res() response: FastifyReply<Response>,
    @Query('domain') domain: string,
    @Query('event') name: string,
    @Query('resource') resource: string,
    // -- referrers and sources --
    @Query('referrer') referrer: string,
    @Query('source') source: string,
    @Query('medium') medium: string,
    @Query('campaign') campaign: string,
    // -- device --
    @Query('device') device: string,
    @Query('deviceType') deviceType: string,
    @Query('width') screenSize: string,
    @Query('touch') touch: string,
    // -- user --
    @Query('timezone') userTimeZone: string,
    @Query('timestamp') userTimestamp: string,
    // -- others --
    @Query('duration') duration: string,
    @Query('completion') completion: string,
    @Query('unique') unique: string,
    @Query('version') version: string,
    @Query('https') https: string,
    @Query('batchId') batchId: string,
    @Query('id') uuid: string,
    // -- headers --
    @Headers('cf-ipcountry') country: string,
    @Headers('user-agent') ua: string = ''
  ) {
    if (!domain || !resource || !name) {
      // TODO: Log request...
      throw new BadRequestException()
    }

    const result = lookup(ua)

    const browser = result.family
    const browserVersion = result.major
    const browserVersionFull = `${result.major}.${result.minor}.${result.patch}`

    const os = result.os.family
    const osVersion = result.os.major
    const osVersionFull = `${result.os.major}.${result.os.minor}.${result.os.patch}`

    if (!device) {
      device = result.device.family
    }

    await this.service.mayBePushEvent({
      domain,

      name,

      resource,
      referrer: referrer ? referrer.split('/')[0] : referrer,
      source,
      medium,
      campaign,

      device,
      deviceType,
      screenSize: coerceInteger(screenSize),

      browser,
      browserVersion,

      os,
      osVersion,

      country,

      userTimeZone,
      userTimestamp: coerceDate(userTimestamp),

      batchId,
      data: {
        uuid,
        version,
        duration: coerceInteger(duration),
        completion: coerceInteger(completion),
        https: coerceBoolean(https),
        touch: coerceBoolean(touch),
        unique: coerceBoolean(touch),
        browserVersionFull,
        osVersionFull,
        referrerFull: referrer,
        javascript: true,
      },
    })

    response
      .header('Cache-Control', 'no-store')
      .header('Content-Type', 'image/gif')

    return response.send(pixel)
  }
}

function coerceInteger(val: string) {
  const int = parseInt(val)

  return Number.isInteger(int) ? int : undefined
}

function coerceDate(val: string) {
  const int = parseInt(val)

  return Number.isInteger(int) ? new Date(int) : undefined
}

function coerceBoolean(val: string) {
  return /^(true|yes|on|1)$/i.test(val)
}
