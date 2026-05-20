const { Client } = require('pg');

async function checkDb() {
  const client = new Client({
    host: 'localhost',
    port: 5433,
    user: 'postgres',
    password: 'postgres',
    database: 'ruangpulih',
  });

  try {
    await client.connect();
    console.log('Connected to DB');

    const userRes = await client.query('SELECT * FROM users');
    console.log('Users:');
    console.table(userRes.rows);

    const res = await client.query('SELECT * FROM forum_posts ORDER BY "createdAt" DESC LIMIT 5');
    console.log('Latest 5 posts:');
    console.table(res.rows);

    const countRes = await client.query('SELECT COUNT(*) FROM forum_posts');
    console.log('Total posts:', countRes.rows[0].count);

    const anonCount = await client.query('SELECT isAnonymous, COUNT(*) FROM forum_posts GROUP BY isAnonymous');
    console.log('Posts by anonymity:');
    console.table(anonCount.rows);

  } catch (err) {
    console.error('Error connecting to DB:', err);
  } finally {
    await client.end();
  }
}

checkDb();
