import { PixelController } from '@/PixelController';
import { PixelService } from '@/PixelService';
import { FastifyReply } from 'fastify';

describe('PixelController', () => {
  let controller: PixelController;
  let service: PixelService;

  beforeEach(() => {
    service = {
      addEvent: () => {},
      addPageView: () => {},
    } as any;
    controller = new PixelController(service);
  });

  describe('getDefaultPixel', () => {
    let response: FastifyReply<Response>;

    beforeEach(() => {
      response = {
        header: () => response,
        code: () => response,
        type: () => response,
        send: () => response,
      } as any;
    });

    it('should capture pageview', async () => {
      const timestamp = '2020-05-22 09:00:30.000';
      const addPageView = jest.spyOn(service, 'addPageView');
      const addEvent = jest.spyOn(service, 'addEvent');

      await controller.getDefaultPixel(
        response,
        'example.com',
        'pageview',
        '/',
        'xxx',
        String(timestamp),
        'IN',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:77.0) Gecko/20100101 Firefox/77.0',
        {}
      );

      expect(addEvent).toHaveBeenCalledTimes(0);
      expect(addPageView).toHaveBeenCalledTimes(1);
      expect(addPageView).toHaveBeenCalledWith(
        expect.objectContaining({
          domain: 'example.com',
          path: '/',
          session: 'xxx',
          browser: 'Firefox',
          browserVersion: '77',
          os: 'Mac OS X',
          osVersion: '10',
          deviceType: 'desktop',
        })
      );
    });

    it('should send 1px gif', async () => {
      const timestamp = '2020-05-22 09:00:30.000';
      const header = jest.spyOn(response, 'header');
      const type = jest.spyOn(response, 'type');
      const code = jest.spyOn(response, 'code');
      const send = jest.spyOn(response, 'send');

      await controller.getDefaultPixel(
        response,
        'example.com',
        'pageread',
        '/',
        'xxx',
        String(timestamp),
        'IN',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:77.0) Gecko/20100101 Firefox/77.0',
        {}
      );

      expect(header).toHaveBeenCalledWith('Cache-Control', 'no-store');
      expect(type).toHaveBeenCalledWith('image/gif');
      expect(code).toHaveBeenCalledWith(200);
      expect(send).toHaveBeenCalledWith(expect.anything());
    });
  });
});
