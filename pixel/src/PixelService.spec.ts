import { Test } from '@nestjs/testing';
import { PixelService } from '@/PixelService';
import { Repository } from 'typeorm';
import { Project, PageView } from '@thesemetrics/database';

jest.mock('dns', () => ({
  lookup: (address: string, callback: Function) =>
    /\.(com|netlify\.app)$/.test(address) ? callback(null, {}) : callback(new Error('Not Found')),
}));

describe('PixelService', () => {
  let service: PixelService;
  let projectRepositoryMock: Repository<Project>;
  let pageViewRepositoryMock: Repository<PageView>;

  beforeEach(async () => {
    projectRepositoryMock = {
      count: () => Promise.resolve(0),
      save: (options: any) => Promise.resolve(options),
      findOneOrFail: () => Promise.resolve({ id: 1 }),
    } as any;

    pageViewRepositoryMock = {
      save: (options: any) => Promise.resolve(options),
    } as any;

    const moduleRef = await Test.createTestingModule({
      providers: [
        PixelService,
        { provide: 'TeamRepository', useValue: {} },
        { provide: 'ProjectRepository', useValue: projectRepositoryMock },
        { provide: 'PageViewRepository', useValue: pageViewRepositoryMock },
        { provide: 'ProjectEventRepository', useValue: {} },
      ],
    }).compile();

    service = moduleRef.get(PixelService);
  });

  describe('isDomainAllowed', () => {
    it('should disallow localhost', async () => {
      expect(await service.isDomainAllowed('localhost')).toBe(false);
      expect(await service.isDomainAllowed('localhost:8080')).toBe(false);
    });

    it('should disallow unregistered domains', async () => {
      expect(await service.isDomainAllowed('example.local')).toBe(false);
      expect(await service.isDomainAllowed('something-non-existing.co')).toBe(false);
      expect(await service.isDomainAllowed('something-existing.com')).toBe(true);
    });

    it('should disallow netlify preview deployments', async () => {
      expect(await service.isDomainAllowed('example.netlify.app')).toBe(true);
      expect(await service.isDomainAllowed('master--example.netlify.app')).toBe(false);
      expect(await service.isDomainAllowed('a41fe131bc2331eabf3--example.netlify.app')).toBe(false);
    });

    it('should create project for new domains', async () => {
      const fn = jest.spyOn(projectRepositoryMock, 'save');

      expect(await service.isDomainAllowed('example.com')).toBe(true);
      expect(fn).toHaveBeenCalledTimes(1);
      expect(fn).toHaveBeenCalledWith({ domain: 'example.com', team: { id: 1 }, name: 'example.com', type: 'website' });
    });
  });

  describe('addPageView', () => {
    const referrers = {
      google: ['google.com', 'google.com/something', 'google.co.in', 'google.it'],
      twitter: ['twitter.com', 'twitter.com/@znck0', 't.co/xyz'],
      facebook: ['facebook.com', 'facebook.com/page'],
      github: ['github.com', 'github.com/page'],
      linkedin: ['linkedin.com', 'linkedin.com/page'],
    };

    it.each(Object.entries(referrers))('should normalize %s', async (referrer, aliases) => {
      const fn = jest.spyOn(pageViewRepositoryMock, 'save');
      for (const alias of aliases) {
        await service.addPageView({ domain: 'example.com', referrer: alias, data: {} } as any);
        expect(fn).toHaveBeenCalledTimes(1);
        expect(fn).toHaveBeenCalledWith(expect.objectContaining({ referrer, data: { referrer: alias } }));
        fn.mockClear();
      }
    });
  });
});
