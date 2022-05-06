module.exports = {
  DB: `${process.env.DB}`,
  POSTGRES_SEEDS: `${process.env.POSTGRES_SEEDS}`,
  DB_PORT: `${process.env.DB_PORT}`,
  POSTGRES_USER: `${process.env.POSTGRES_USER}`,
  POSTGRES_PWD: `${process.env.POSTGRES_PWD}`,
  TEMPORAL_HOME: '/etc/temporal',
  TEMPORAL_CLI_ADDRESS: `${process.env.TEMPORAL_CLI_ADDRESS}`
}
