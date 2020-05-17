// @ts-check
const typeorm = require('typeorm');
const config = require('../ormconfig');

function yesterday() {
  const date = new Date();

  date.setDate(date.getDate() - 1);

  return date;
}

let connection;
async function run(date = yesterday()) {
  connection =
    connection ||
    (await typeorm.createConnection({
      type: 'postgres',
      url: config.url,
    }));

  await connection.transaction(async (connection) => {
    await Promise.all([
      connection.query('SELECT compute_daily_device_pageviews($1::DATE)', [date]),
      connection.query('SELECT compute_daily_aggregate_pageviews($1::DATE)', [date]),
      connection.query(`SELECT compute_daily_aggregate_referrer_pageviews('referrer', $1::DATE)`, [date]),
    ]);
  });
}

async function main(start = yesterday(), end = yesterday()) {
  start = new Date(start);
  end = new Date(end);

  const cur = new Date(start.getTime());
  while (cur.getTime() <= end.getTime()) {
    await run(cur.toISOString().split('T')[0]);

    cur.setDate(cur.getDate() + 1);
  }
}

main(process.argv[2], process.argv[3]);
