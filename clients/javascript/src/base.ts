const basePayload /*#__PURE__*/ = {
  domain: window.location.hostname,
  referrer: getReferrer() as string | undefined,
  // -- device ---
  width: window.innerWidth,
  touch: isTouchDevice(),
  // -- user --
  timezone: getTimeZone(),
  // -- others ---
  https: window.location.protocol === 'https',
  version: 1,
  unique: isUnique(),
  session: getBatchId(),
};

const config /*#__PURE__*/ = {
  mode: null as 'hash' | null,
  baseUrl: 'https://pixel.thesemetrics.xyz/default.gif',
  debug: false,
  utm: {
    source: ['utm_source', 'ref', 'source'],
    medium: ['utm_medium'],
    campaign: ['utm_campaign'],
  },
  additional_utm_keys: ['utm_term', 'utm_content'],
  getScrollElement(): HTMLElement {
    return document.documentElement;
  },
};

export function setConfig(options: Partial<typeof config>) {
  Object.assign(config, options);
}

export function getConfig(): Readonly<typeof config> {
  return config;
}

const getDuration /*#__PURE__*/ = createDuration();
const getCompletion /*#__PURE__*/ = createCompletion();

export interface Options {}
let previousHash = window.location.hash;
export function sendPageReadEvent() {
  const duration = getDuration();
  const completion = getCompletion();
  const options: Partial<PageReadEvent> = { duration, completion };

  if (config.mode === 'hash') {
    options.path = getResource(previousHash);
  }

  return sendEvent('pageread', options);
}

export function sendPageViewEvent() {
  previousHash = window.location.hash;

  return sendEvent('pageview', basePayload);
}

interface BaseEvent {
  id: string;
  timestamp: string;

  [key: string]: any;
}

interface PageViewEvent extends BaseEvent {
  event: 'pageview';
  path: string;
}

interface PageReadEvent extends BaseEvent {
  event: 'pageread';
  path: string;

  duration: number;
  completion: number;
}

type TheseMetricsEvent = PageReadEvent | PageViewEvent;

let prevEvent: null | TheseMetricsEvent /*#__PURE__*/ = null;
let firstEvent: null | TheseMetricsEvent /*#__PURE__*/ = null;

function sendEvent(event: TheseMetricsEvent['event'], options: Partial<TheseMetricsEvent> = Object.create(null)) {
  const path = getResource();

  if (prevEvent && prevEvent.event === event && prevEvent.path === path) {
    return; // ignore duplicate event.
  }

  const payload: TheseMetricsEvent = {
    id: uuid(),
    domain: basePayload.domain,
    event,
    path,
    session: basePayload.session,
    timestamp: now(),
    ...options,
  } as any;

  if (!firstEvent) {
    const utm = getUTMParams();
    Object.assign(payload, utm);
  }

  if (config.debug) {
    console.log(config.baseUrl, payload);
  }

  new Image().src = `${config.baseUrl}?${Object.entries(payload)
    .filter(([, value]) => value != null)
    .map(([key, value]) => `${key}=${encodeURIComponent(value as any)}`)
    .join('&')}`;

  basePayload.referrer = undefined;
  basePayload.unique = false;

  prevEvent = payload;
  if (!firstEvent) firstEvent = payload;

  return payload;
}

function getResource(hash = window.location.hash) {
  if (config.mode === 'hash') {
    return hash ? hash.split('?')[0] || '/' : '/';
  }

  return window.location.pathname || '/';
}

function getUTMParams() {
  const query = parseQuery();
  const utm: Record<string, any> = {
    source: config.utm.source.find((key) => query[key]),
    medium: config.utm.medium.find((key) => query[key]),
    campaign: config.utm.campaign.find((key) => query[key]),
  };

  config.additional_utm_keys.forEach((key) => {
    utm[key.startsWith('utm_') ? key : 'utm_' + key] = query[key];
  });

  return utm;
}

function parseQuery() {
  const query = window.location.search;
  const params: Record<string, string | boolean> = {};
  if (query) {
    query.split('&').forEach((part) => {
      const [key, value] = part.split('=');
      params[key] = value ? decodeURIComponent(value) : true;
    });
  }
  return params;
}

function isTouchDevice(): boolean {
  return (
    'ontouchstart' in window ||
    (typeof window.DocumentTouch === 'function' && document instanceof window.DocumentTouch) ||
    ('msMaxTouchPoints' in navigator && navigator.msMaxTouchPoints > 0)
  );
}

function getTimeZone() {
  try {
    return new Intl.DateTimeFormat().resolvedOptions().timeZone;
  } catch {
    return 'Other';
  }
}

function isUnique() {
  const { performance } = window;

  if (performance && !!performance.getEntriesByType) {
    const [first] = performance.getEntriesByType('navigation');

    if (first && /^(reload|back_forward|1|2)$/i.test(String((<any>first).type))) {
      return false;
    }
  }

  const referrer = getReferrer();

  if (referrer) {
    return (
      referrer
        .replace(/^https?:\/\//, '')
        .split('/', 1)[0]
        .split(':', 1)[0] !== window.location.hostname
    );
  }

  return true;
}

function getReferrer() {
  return document.referrer ? document.referrer.replace(/^https?:\/\//i, '').split('?', 2)[0] : undefined;
}

function uuid() {
  // @ts-ignore
  const crypto = window.crypto || window.msCrypto;
  const val = 1e7 + '' + -1e3 + -4e3 + -8e3 + -1e11;

  if (!crypto)
    return val.replace(/[018]/g, (c) => {
      const r = (Math.random() * 16) | 0,
        v = +c < 2 ? r : (r & 0x3) | 0x8;
      return v.toString(16);
    });

  return val.replace(/[018]/g, (c) =>
    (+c ^ (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (+c / 4)))).toString(16)
  );
}

function createDuration() {
  let start = Date.now();
  let hidden = 0;
  let hiddenStart = 0;

  window.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      hiddenStart = Date.now();
    } else if (hiddenStart) {
      hidden += hiddenStart - Date.now();
    }
  });

  return () => {
    const duration = Date.now() - start - hidden;

    start = Date.now();
    hidden = 0;

    return duration;
  };
}

function createCompletion() {
  let scrolled = 0;
  window.addEventListener('load', () => {
    scrolled = getScrollPosition();

    window.addEventListener(
      'scroll',
      () => {
        scrolled = Math.max(scrolled, getScrollPosition());
      },
      true
    );
  });

  return () => Math.floor((scrolled / getScrollHeight()) * 100);
}

function getScrollPosition() {
  let position = 0;

  try {
    position = config.getScrollElement().scrollTop;
  } catch {}

  return Number.isFinite(position) ? position : 0;
}

function getScrollHeight() {
  let position = 0;
  try {
    position = config.getScrollElement().scrollHeight;
  } catch {}

  return Number.isFinite(position) ? Math.max(1, position) : 1;
}

const KEY /*#__PURE__*/ = '__batch_id__';
function getBatchId() {
  const session = uuid();

  // TODO: ensure this doesn't violate GDPR/CCPA/PECR
  const prevBatchId = sessionStorage.getItem(KEY);
  if (prevBatchId) return prevBatchId;
  sessionStorage.setItem(KEY, session);

  return session;
}

function now() {
  const date = new Date();

  return (
    `${date.getFullYear()}-${digit(date.getMonth() + 1)}-${digit(date.getDate())}` +
    ' ' +
    `${digit(date.getHours())}:${digit(date.getMinutes())}:${digit(date.getSeconds())}`
  );
}

function digit(val: number) {
  return String(val).padStart(2, '0');
}
