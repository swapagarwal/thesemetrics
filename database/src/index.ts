export { Team, TeamType } from './Team';
export { User } from './User';
export { Project, ProjectType } from './Project';
export { PageView } from './PageView';
export { DailyAggregateDevice } from './DailyAggregateDevice';
export { DailyAggregatePageView } from './DailyAggregatePageView';
export { DailyAggregateReferrerPageView, ReferrerKind } from './DailyAggregateReferrerPageView';
export { ProjectEvent } from './ProjectEvent';

import * as fs from 'fs';

export function config() {
  let url = process.env.POSTGRES_URL;
  let ca = process.env.POSTGRES_CERTIFICATE;

  if (!url) {
    if (fs.existsSync('/var/secrets/database_uri')) {
      url = fs.readFileSync('/var/secrets/database_uri', { encoding: 'utf-8' });
    } else if (process.env.NODE_ENV !== 'production') {
      url = 'postgres://user:pass@localhost:5432/analytics';
    }
  }

  if (!ca) {
    if (fs.existsSync('/var/secrets/database_ssl_certificate')) {
      ca = fs.readFileSync('/var/secrets/database_ssl_certificate', { encoding: 'utf-8' });
    }

    if (ca && !ca.trim().startsWith('-----BEGIN CERTIFICATE-----')) ca = undefined;
  }

  return {
    type: 'postgres' as 'postgres',
    url: url,
    ssl: ca ? { ca } : false,
  };
}
