declare module 'device' {
  function parse(ua: string): { type: string };

  export = parse;
}
