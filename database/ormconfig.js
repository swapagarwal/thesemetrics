if (process.env.NODE_ENV !== 'production') {
  process.env.POSTGRES_URL = process.env.POSTGRES_URL || 'postgres://user:pass@localhost:5432/analytics'
}

module.exports = {
  type: 'postgres',
  url: process.env.POSTGRES_URL,
  entities: [],
  migrations: ['migrations/*.js'],
  cli: {
    migrationsDir: 'migrations',
  },
};
