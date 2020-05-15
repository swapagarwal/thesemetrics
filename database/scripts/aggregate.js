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
  const date = DATE.toISOString().split('T')[0];

  await connection.transaction(async (connection) => {
    await Promise.all([
      // PageReads
      connection.query(`SELECT compute_daily_total_page_reads($1::date)`, [date]),
      connection.query(`SELECT compute_daily_page_reads('resource', $1::date)`, [date]),
      // PageViews
      connection.query(`SELECT compute_daily_total_page_views($1::date)`, [date]),
      connection.query(`SELECT compute_daily_total_unique_page_views($1::date)`, [date]),
      connection.query(`SELECT compute_daily_page_views('resource', $1::date)`, [date]),
      connection.query(`SELECT compute_daily_unique_page_views('resource', $1::date)`, [date]),
      // UTM/Referrer
      connection.query(`SELECT compute_daily_page_views('source', $1::date)`, [date]),
      connection.query(`SELECT compute_daily_page_views('medium', $1::date)`, [date]),
      connection.query(`SELECT compute_daily_page_views('campaign', $1::date)`, [date]),
      connection.query(`SELECT compute_daily_page_views('referrer', $1::date)`, [date]),
      // Browser/Device/OS
      connection.query(`SELECT compute_daily_page_views('device', $1::date)`, [date]),
      connection.query(`SELECT compute_daily_page_views('browser', $1::date)`, [date]),
      connection.query(`SELECT compute_daily_page_views('os', $1::date)`, [date]),
      // Geo/Demographic
      connection.query(`SELECT compute_daily_page_views('country', $1::date)`, [date]),
      connection.query(`SELECT compute_daily_page_views('timeZone', $1::date)`, [date]),
    ]);

    // Lets run weekly stuff on Monday
    if (true) {
      await Promise.all([
        // PageReads
        connection.query(`SELECT compute_weekly_total_page_reads($1::date)`, [date]),
        connection.query(`SELECT compute_weekly_page_reads('resource', $1::date)`, [date]),
        // PageViews
        connection.query(`SELECT compute_weekly_total_page_views($1::date)`, [date]),
        connection.query(`SELECT compute_weekly_total_unique_page_views($1::date)`, [date]),
        connection.query(`SELECT compute_weekly_page_views('resource', $1::date)`, [date]),
        connection.query(`SELECT compute_weekly_unique_page_views('resource', $1::date)`, [date]),
        // UTM/Referrer
        connection.query(`SELECT compute_weekly_page_views('source', $1::date)`, [date]),
        connection.query(`SELECT compute_weekly_page_views('medium', $1::date)`, [date]),
        connection.query(`SELECT compute_weekly_page_views('campaign', $1::date)`, [date]),
        connection.query(`SELECT compute_weekly_page_views('referrer', $1::date)`, [date]),
        // Browser/Device/OS
        connection.query(`SELECT compute_weekly_page_views('device', $1::date)`, [date]),
        connection.query(`SELECT compute_weekly_page_views('browser', $1::date)`, [date]),
        connection.query(`SELECT compute_weekly_page_views('os', $1::date)`, [date]),
        // Geo/Demographic
        connection.query(`SELECT compute_weekly_page_views('country', $1::date)`, [date]),
        connection.query(`SELECT compute_weekly_page_views('timeZone', $1::date)`, [date]),
      ]);
    }

    await Promise.all([
      // PageReads
      connection.query(`SELECT compute_total_page_reads()`),
      connection.query(`SELECT compute_page_reads('resource')`),
      // PageViews
      connection.query(`SELECT compute_total_page_views()`),
      connection.query(`SELECT compute_total_unique_page_views()`),
      connection.query(`SELECT compute_total_page_views_by_hour()`),
      connection.query(`SELECT compute_total_unique_page_views_by_hour()`),
      connection.query(`SELECT compute_page_views('resource')`),
      connection.query(`SELECT compute_unique_page_views('resource')`),
      // UTM/Referrer
      connection.query(`SELECT compute_page_views('source')`),
      connection.query(`SELECT compute_page_views('medium')`),
      connection.query(`SELECT compute_page_views('campaign')`),
      connection.query(`SELECT compute_page_views('referrer')`),
      // Geo/Demographic
      connection.query(`SELECT compute_page_views('country')`),
      connection.query(`SELECT compute_page_views('timeZone')`),
    ]);
  });
}

main().catch((error) => {
  console.error(error);
});
