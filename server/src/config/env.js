const dotenv = require("dotenv");
dotenv.config();

const {
  DB_NAME,
  DB_USERNAME,
  DB_PASSWORD,
  DB_HOST,
  DB_PORT,
  SSL,
  DB_DIALECT,
  KHALTI_SECRET_KEY,
  KHALTI_GATEWAY_URL,
  BACKEND_URI,
} = process.env;

module.exports = {
  DB_NAME,
  DB_USERNAME,
  DB_PASSWORD,
  DB_HOST,
  DB_PORT,
  SSL,
  DB_DIALECT,
KHALTI_SECRET_KEY,
  KHALTI_GATEWAY_URL,
  BACKEND_URI,
};
