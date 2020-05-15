// @ts-check
const typeorm = require('typeorm');
const Path = require('path');
const FS = require('fs');

/**
 * @param {string} contents
 */
function getQueries(contents) {
  return contents
    .split('-->')
    .map((str) => str.trim().replace(/;$/, ''))
    .filter((str) => !!str.trim());
}

async function main() {
  const connection = await typeorm.createConnection({
    type: 'postgres',
    url: process.env.POSTGRES_URL,
  });

  await connection.transaction(async (connection) => {
    const fileName = Path.resolve(__dirname, '../migrations/seed.sql');
    const contents = await FS.promises.readFile(fileName, 'utf-8');
    await Promise.all(getQueries(contents).map((query) => connection.query(query)));
  });
}

main();
