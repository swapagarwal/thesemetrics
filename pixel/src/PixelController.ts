import { BadRequestException, Controller, Get, Headers, Query, Res } from '@nestjs/common';
import getDevice from 'device';
import { FastifyReply } from 'fastify';
import { lookup } from 'useragent';
import { PixelService } from './PixelService';

const pixel = Buffer.from('R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs=', 'base64');

@Controller()
export class PixelController {
  constructor(private readonly service: PixelService) {}

  @Get('/default.gif')
  public async getDefaultPixel(
    @Res() response: FastifyReply<Response>,
    @Query('domain') domain: string,
    @Query('event') name: string,
    @Query('path') path: string,
    @Query('session') session: string,
    @Query('timestamp') timestamp: string,
    @Headers('cf-ipcountry') country: string,
    @Headers('user-agent') ua: string = '',
    @Query() query: Record<string, string>
  ) {
    response.header('Cache-Control', 'no-store');

    if (!domain || !path || !name) {
      throw new BadRequestException();
    }

    if (name === 'pageview') {
      const result = lookup(ua);

      const browser = result.family;
      const browserVersion = result.major;
      const browserVersionFull = `${result.major}.${result.minor}.${result.patch}`;

      const os = result.os.family;
      const osVersion = result.os.major;
      const osVersionFull = `${result.os.major}.${result.os.minor}.${result.os.patch}`;

      const device = result.device.family;
      const deviceType = getDevice(ua).type as string;
      const utm: Record<string, string> = {};

      Object.keys(query).forEach((key) => {
        if (key.startsWith('utm_')) {
          utm[key.replace(/^utm_/, '')] = query[key];
        }
      });

      await this.service.addPageView({
        domain,

        path,
        session: session,
        unique: coerceBoolean(query.unique),

        device,
        deviceType,
        browser,
        browserVersion,
        os,
        osVersion,
        screenSize: coerceInteger(query.screenSize) || 0,

        source: query.source,
        medium: query.medium,
        campaign: query.campaign,
        referrer: query.referrer,

        country,
        timezone: query.timezone,
        timestamp: timestamp as any,

        data: {
          uuid: query.id,
          version: query.version,
          https: coerceBoolean(query.https),
          touch: coerceBoolean(query.touch),
          javascript: true,
          browserVersion: browserVersionFull,
          osVersion: osVersionFull,
          utm: Object.keys(utm).length ? utm : undefined,
        },
      });
    } else if (name === 'pageread') {
      await this.service.addEvent({
        domain,
        name,
        path,
        session,
        timestamp: timestamp as any,
        data: {
          uuid: query.id,
          version: query.version,
          duration: coerceInteger(query.duration) as number,
          completion: coerceInteger(query.completion) as number,
        },
      });
    }

    return response.code(200).type('image/gif').send(pixel);
  }
}

function coerceInteger(val: string) {
  const int = parseInt(val);

  return Number.isInteger(int) ? int : undefined;
}

function coerceDate(val: string) {
  const date = /^[0-9]+$/.test(val) ? new Date(Number(val)) : new Date(val);

  return Number.isNaN(date.getTime()) ? undefined : date;
}

function coerceBoolean(val: string) {
  return /^(true|yes|on|1)$/i.test(val);
}
