function randomInt(start: number, end: number) {
  return Math.floor(start + (end - start) * Math.random());
}

function randomItem<T>(items: T[]) {
  return items[randomInt(0, items.length - 1)];
}

export const generateFakePageViews = () =>
  Array(29)
    .fill(0)
    .map(
      (_, id) =>
        ({
          id: id,
          date: new Date(`2020-05-${String(id+1).padStart(2, '0')}`),
          resource: randomItem(['/', '/blog', '/about', '/login', '/blog/2020-01-first-post']),
          count: randomInt(1000, 50000),
        } as DailyPageViewEvent)
    );

export interface DailyPageViewEvent {
  id: number;
  date: Date;
  resource: string;
  count: number;
}
