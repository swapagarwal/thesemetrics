import {
  setConfig,
  sendPageViewEvent,
  getConfig,
  sendPageReadEvent,
} from './base'

function getCurrentScript() {
  if (document.currentScript && document.currentScript.tagName === '') {
    return document.currentScript as HTMLScriptElement
  } else {
    const stack = new Error().stack
    const scripts = Array.from(document.querySelectorAll('script[src]'))

    if (stack) {
      const match = /https?:\/\/.*?\.js/i.exec(stack)

      if (match) {
        const url = match[0].split('/').pop()!
        return scripts.find((script) => {
          const src = script.getAttribute('src')
          return !!src && src.endsWith(url)
        }) as HTMLScriptElement
      }
    }
  }
}

function getBaseUrl(base?: string) {
  if (base) {
    return (
      (__DEV__ ? 'http://' : 'https://') +
      base.replace(/^(https?:)?\/\//, '').split('/')[0] +
      '/default.gif'
    )
  }

  return 'https://pixel.thesemetrics.xyz/default.gif'
}

// ------- Send event -------

const script = getCurrentScript()
const dataset = script ? script.dataset : {}

setConfig({
  baseUrl: getBaseUrl(dataset.base),
  mode: dataset.mode === 'hash' ? 'hash' : null,
  debug: 'debug' in dataset && dataset.debug !== 'false',
  getScrollElement() {
    return dataset.scrollSelector
      ? document.querySelector(dataset.scrollSelector) ||
          document.documentElement
      : document.documentElement
  },
})

sendPageViewEvent()

if (getConfig().mode === 'hash') {
  window.addEventListener('hashchange', () => {
    sendPageReadEvent()
    sendPageViewEvent()
  })
}

const { history } = window
if (history) {
  const pushState = history.pushState
  history.pushState = function () {
    const result = pushState.apply(this, arguments as any)
    sendPageViewEvent()
    return result
  }

  const replaceState = history.replaceState
  history.replaceState = function () {
    sendPageReadEvent()
    const result = replaceState.apply(this, arguments as any)
    sendPageViewEvent()
    return result
  }
}
window.addEventListener('popstate', sendPageReadEvent, false)
window.addEventListener('unload', sendPageReadEvent)
