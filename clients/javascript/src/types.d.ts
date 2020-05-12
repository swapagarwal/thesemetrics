declare global {
  interface Window {
    DocumentTouch?: Function
  }

  const __DEV__: boolean
}

export {}