const basePayload /*#__PURE__*/ = {
  domain: window.location.hostname,
  referrer: getReferrer(),
  // -- device ---
  width: window.innerWidth,
  touch: isTouchDevice(),
  // -- user --
  timezone: getTimeZone(),
  // -- others ---
  https: window.location.protocol === 'https',
  version: 1,
  unique: isUnique(),
  batchId: getBatchId(), 
  
  // TODO: Process utm stuff.
}

const config /*#__PURE__*/ = {
  mode: null as 'hash' | null,
  baseUrl: null as string | null,
  debug: false,
  getScrollElement(): HTMLElement {
    return document.documentElement
  },
}

export function setConfig(options: Partial<typeof config>) {
  Object.assign(config, options)
}

export function getConfig(): Readonly<typeof config> {
  return config
}

const getDuration /*#__PURE__*/ = createDuration()
const getCompletion /*#__PURE__*/ = createCompletion()

export interface Options {}

let previousHash = window.location.hash
export function sendPageReadEvent() {
  const duration = getDuration()
  const completion = getCompletion()
  const options: Partial<PageReadEvent> = { duration, completion }

  if (config.mode === 'hash') {
    options.resource = getResource(previousHash)
  }

  return sendEvent('pageread', options)
}

export function sendPageViewEvent() {
  previousHash = window.location.hash

  return sendEvent('pageview')
}

interface BaseEvent {
  id: string
  timestamp: number

  [key: string]: any
}

interface PageViewEvent extends BaseEvent {
  event: 'pageview'
  resource: string
}

interface PageReadEvent extends BaseEvent {
  event: 'pageread'
  resource: string

  duration: number
  completion: number
}

type TheseMetricsEvent = PageReadEvent | PageViewEvent

let prevEvent: null | TheseMetricsEvent /*#__PURE__*/ = null
let firstEvent: null | TheseMetricsEvent /*#__PURE__*/ = null

function sendEvent(
  event: TheseMetricsEvent['event'],
  options: Partial<TheseMetricsEvent> = Object.create(null)
) {
  const resource = getResource()

  if (
    prevEvent &&
    prevEvent.event === event &&
    prevEvent.resource === resource
  ) {
    return // ignore duplicate event.
  }

  const payload: TheseMetricsEvent = {
    id: uuid(),
    event,
    resource,
    timestamp: Date.now(),

    ...basePayload,
    ...options,
  } as any

  if (config.debug) {
    console.log(config.baseUrl, payload)
  }

  new Image().src = `${config.baseUrl}?${Object.entries(payload)
    .filter(([, value]) => value != null)
    .map(([key, value]) => `${key}=${encodeURIComponent(value as any)}`)
    .join('&')}`

  basePayload.referrer = undefined
  basePayload.unique = false

  prevEvent = payload
  if (!firstEvent) firstEvent = payload

  return payload
}

function getResource(hash = window.location.hash) {
  if (config.mode === 'hash') {
    return hash ? hash.split('?')[0] || '/' : '/'
  }

  return window.location.pathname || '/'
}

function isTouchDevice(): boolean {
  return (
    'ontouchstart' in window ||
    (typeof window.DocumentTouch === 'function' &&
      document instanceof window.DocumentTouch) ||
    ('msMaxTouchPoints' in navigator && navigator.msMaxTouchPoints > 0)
  )
}

function getTimeZone() {
  try {
    return new Intl.DateTimeFormat().resolvedOptions().timeZone
  } catch {
    return 'Other'
  }
}

function isUnique() {
  const { performance } = window

  if (performance && !!performance.getEntriesByType) {
    const [first] = performance.getEntriesByType('navigation')

    if (
      first &&
      /^(reload|back_forward|1|2)$/i.test(String((<any>first).type))
    ) {
      return false
    }
  }

  return getReferrer() !== window.location.hostname
}

function getReferrer() {
  return document.referrer
    ? document.referrer
        .replace(/^https?:\/\/((m|l|w{2,3}([0-9]+)?)\.)?([^?#]+)(.*)$/, '$4')
        .replace(/^([^/]+)\/$/, '$1')
    : undefined
}

function uuid() {
  // @ts-ignore
  const crypto = window.crypto || window.msCrypto
  const val = 1e7 + '' + -1e3 + -4e3 + -8e3 + -1e11

  if (!crypto)
    return val.replace(/[018]/g, (c) => {
      const r = (Math.random() * 16) | 0,
        v = +c < 2 ? r : (r & 0x3) | 0x8
      return v.toString(16)
    })

  return val.replace(/[018]/g, (c) =>
    (
      +c ^
      (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (+c / 4)))
    ).toString(16)
  )
}

function createDuration() {
  let start = Date.now()
  let hidden = 0
  let hiddenStart = 0

  window.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      hiddenStart = Date.now()
    } else if (hiddenStart) {
      hidden += hiddenStart - Date.now()
    }
  })

  return () => {
    const duration = Date.now() - start - hidden

    start = Date.now()
    hidden = 0

    return duration
  }
}

function createCompletion() {
  let scrolled = 0
  window.addEventListener('load', () => {
    scrolled = getScrollPosition()

    window.addEventListener(
      'scroll',
      () => {
        scrolled = Math.max(scrolled, getScrollPosition())
      },
      true
    )
  })

  return () => Math.floor((scrolled / getScrollHeight()) * 100)
}

function getScrollPosition() {
  let position = 0

  try {
    position = config.getScrollElement().scrollTop
  } catch (error) {
    console.error(error)
  }

  return Number.isFinite(position) ? position : 0
}

function getScrollHeight() {
  let position = 0
  try {
    position = config.getScrollElement().scrollHeight
  } catch (error) {
    console.error(error)
  }

  return Number.isFinite(position) ? Math.max(1, position) : 1
}

function getBatchId() {
  const batchId = uuid()

  // TODO: ensure this doesn't violate GDPR/CCPA/PECR
  const prevBatchId = sessionStorage.getItem('__batch_id__')
  if (prevBatchId) return prevBatchId
  sessionStorage.setItem('__batch_id__', batchId)

  return batchId
}
