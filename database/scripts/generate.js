#!/usr/bin/env node

const Path = require('path')
const FileSystem = require('fs').promises

const migrationsDir = Path.resolve(__dirname, '..', 'migrations')

function indent(content, width = 6) {
  const prefix = ' '.repeat(width)

  return content
    .trim()
    .split('\n')
    .map((line) => prefix + line)
    .join('\n')
}

async function main() {
  const files = (await FileSystem.readdir(migrationsDir)).filter((fileName) =>
    /^\d{4}_.*\.sql$/.test(fileName)
  )

  const migrations = Array.from(
    new Set(files.map((fileName) => fileName.replace(/\.(up|down)\.sql$/, '')))
  )

  async function getQueries(fileName) {
    if (!files.includes(fileName)) return []
    const contents = await FileSystem.readFile(
      Path.resolve(migrationsDir, fileName),
      { encoding: 'utf8' }
    )

    return contents.split(';')
  }

  async function getUpQueries(migration) {
    return getQueries(migration + '.up.sql')
  }

  async function getDownQueries(migration) {
    return getQueries(migration + '.down.sql')
  }

  migrations.map(async (migration) => {
    const migrationFile = Path.resolve(migrationsDir, migration + '.js')
    const [, id, name] = /^(\d{4})_(.*)$/.exec(migration)
    const className = `Migration_${name.replace(/[^a-zA-Z0-9$_]+/g, '_')}_158928020${id}`

    await FileSystem.writeFile(
      migrationFile,
      [
        `module.exports = class ${className} {`,
        `  async up(runner) {`,
        ...(await getUpQueries(migration)).map(
          (query) => '    await runner.query(`\n' + indent(query) + '\n    `)'
        ),
        `  }`,
        ``,
        `  async down(runner) {`,
        ...(await getDownQueries(migration)).map(
          (query) => '    await runner.query(`\n' + indent(query) + '\n    `)'
        ),
        `  }`,
        `}`,
      ].join('\n')
    )
  })
}

main().catch(console.error)
