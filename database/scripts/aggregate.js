// @ts-check
const typeorm = require('typeorm');

function yesterday() {
  const date = new Date();

  date.setDate(date.getDate() - 1);

  return date;
}

async function main() {
  const connection = await typeorm.createConnection({
    type: 'postgres',
    url: process.env.POSTGRES_URL,
  });

  const DATE = yesterday();
  const date = '2020-05-13';

  await connection.transaction(async (connection) => {
    await Promise.all([
      connection.query('SELECT compute_daily_device_pageviews($1::DATE)', [date]),
      connection.query('SELECT compute_daily_aggregate_pageviews($1::DATE)', [date]),
    ]);
  });
}

main().catch((error) => {
  console.error(error);
});
