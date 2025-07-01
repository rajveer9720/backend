const mysql = require('mysql2/promise');
require('dotenv').config();

async function testDatabaseConnection() {
  console.log('🔍 Testing MySQL Connection...');
  console.log('================================');
  
  const config = {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USERNAME || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'nestjs_auth_db'
  };
  
  console.log('Configuration:');
  console.log(`Host: ${config.host}`);
  console.log(`Port: ${config.port}`);
  console.log(`Username: ${config.user}`);
  console.log(`Password: ${config.password ? '***hidden***' : '(empty)'}`);
  console.log(`Database: ${config.database}`);
  console.log('');

  try {
    // Test connection without database first
    const connectionWithoutDB = await mysql.createConnection({
      host: config.host,
      port: config.port,
      user: config.user,
      password: config.password
    });
    
    console.log('✅ Connection to MySQL server successful!');
    
    // Check if database exists
    const [databases] = await connectionWithoutDB.execute('SHOW DATABASES');
    const dbExists = databases.some(db => db.Database === config.database);
    
    if (!dbExists) {
      console.log(`⚠️  Database '${config.database}' doesn't exist. Creating it...`);
      await connectionWithoutDB.execute(`CREATE DATABASE IF NOT EXISTS \`${config.database}\``);
      console.log(`✅ Database '${config.database}' created successfully!`);
    } else {
      console.log(`✅ Database '${config.database}' already exists.`);
    }
    
    await connectionWithoutDB.end();
    
    // Test connection with database
    const connectionWithDB = await mysql.createConnection(config);
    console.log('✅ Connection to database successful!');
    await connectionWithDB.end();
    
    console.log('');
    console.log('🎉 All tests passed! Your NestJS app should be able to connect to MySQL.');
    
  } catch (error) {
    console.error('❌ Connection failed!');
    console.error('Error:', error.message);
    console.log('');
    console.log('💡 Troubleshooting tips:');
    
    if (error.code === 'ER_ACCESS_DENIED_ERROR') {
      console.log('   - Check your username and password');
      console.log('   - Try connecting with: mysql -u root -p');
      console.log('   - Consider creating a new MySQL user');
    } else if (error.code === 'ECONNREFUSED') {
      console.log('   - Make sure MySQL server is running');
      console.log('   - Check if the port 3306 is correct');
      console.log('   - Verify MySQL service is started');
    } else if (error.code === 'ER_BAD_DB_ERROR') {
      console.log('   - The database name might be incorrect');
      console.log('   - Try creating the database manually');
    }
    
    console.log('   - See MYSQL_SETUP_GUIDE.md for detailed instructions');
  }
}

testDatabaseConnection();
