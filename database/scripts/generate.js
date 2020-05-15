#!/usr/bin/env node

const Path = require('path');
const FileSystem = require('fs').promises;

const migrationsDir = Path.resolve(__dirname, '..', 'migrations');

/**
 * @param {string} content
 * @param {number} width
 */
function indent(content, width = 6) {
  const prefix = ' '.repeat(width);

  return content
    .trim()
    .split('\n')
    .map((line) => prefix + line)
    .join('\n');
}

async function main() {
  const files = (await FileSystem.readdir(migrationsDir)).filter((fileName) =>
    /^\d{4}_.*\.(up|down)\.sql$/.test(fileName)
  );

  const migrations = Array.from(new Set(files.map((fileName) => fileName.replace(/\.(up|down)\.sql$/, ''))));

  /**
   * @param {string} fileName
   */
  async function getQueries(fileName) {
    if (!files.includes(fileName)) return [];
    const contents = await FileSystem.readFile(Path.resolve(migrationsDir, fileName), { encoding: 'utf8' });

    return contents
      .split('-->')
      .map((str) => str.trim().replace(/;$/, ''))
      .filter((str) => !!str.trim());
  }

  /**
   * @param {string} migration
   */
  async function getUpQueries(migration) {
    return getQueries(migration + '.up.sql');
  }

  /**
   * @param {string} migration
   */
  async function getDownQueries(migration) {
    return getQueries(migration + '.down.sql');
  }

  await Promise.all(
    migrations.map(async (migration) => {
      const migrationFile = Path.resolve(migrationsDir, migration + '.js');
      const result = /^(\d{4})_(.*)$/.exec(migration);
      if (!result) return;
      const [, id, name] = result;
      const className = `Migration_${name.replace(/[^a-zA-Z0-9$_]+/g, '_')}_158928020${id}`;

      await FileSystem.writeFile(
        migrationFile,
        [
          `module.exports = class ${className} {`,
          `  async up(runner) {`,
          ...(await getUpQueries(migration)).map((query) => '    await runner.query(`\n' + indent(query) + '\n    `)'),
          `  }`,
          ``,
          `  async down(runner) {`,
          ...(await getDownQueries(migration)).map(
            (query) => '    await runner.query(`\n' + indent(query) + '\n    `)'
          ),
          `  }`,
          `}`,
        ].join('\n')
      );
    })
  );
}

main().catch(console.error);
