const mysql = require("mysql2");

/*
LOCAL:
 export DB_HOST=localhost
AWS:
 values injected from SSM via EC2 user-data
*/

module.exports = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME
});
