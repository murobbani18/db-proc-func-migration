const express = require('express');
const mysql = require('mysql2'); // Pastikan Anda menginstal mysql2
const app = express();
const PORT = 3000;

// Konfigurasi koneksi database
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '', // Ganti dengan password Anda
  database: 'rsfatmawati' // Ganti dengan nama database Anda
});

// Middleware untuk parsing JSON
app.use(express.json());

// Rute dasar
app.get('/api/v1', (req, res) => {
  res.send('Hello, World!');
});

// Rute untuk menerima request GET
app.get('/api/v1/datatable', (req, res) => {
  const { pn, page = 1, per_page = 10, filter = '{}' } = req.query; // Mengambil parameter dari query string

  // Memanggil prosedur yang sesuai
  const sql = `SELECT ${pn}(${mysql.escape(per_page)}, ${mysql.escape(page)}, ${mysql.escape(filter)}) as data`;

  db.query(sql, (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      return res.status(500).json({ error: 'Database query failed' });
    }

    // Mengembalikan hasil sebagai JSON
    res.json(results[0].data); // Hasil dari prosedur biasanya ada di results[0]
  });
});


// Rute untuk menerima request GET
app.get('/api/v1/data', (req, res) => {
  const { pn, filter = '{}' } = req.query; // Mengambil parameter dari query string

  // Memanggil prosedur yang sesuai
  const sql = `SELECT ${pn}(${mysql.escape(filter)}) as data`;

  db.query(sql, (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      return res.status(500).json({ error: 'Database query failed' });
    }

    // Mengembalikan hasil sebagai JSON
    res.json(results[0].data); // Hasil dari prosedur biasanya ada di results[0]
  });
});

// Rute untuk menerima request POST Create data
app.post('/api/v1/data', (req, res) => {
  const { pn, data } = req.body; // Mengambil p, d dari body
  
  // Memanggil prosedur yang sesuai
  const sql = `CALL ${pn}(${mysql.escape(JSON.stringify(data))})`;

  db.query(sql, (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      return res.status(500).json({ error: 'Database query failed' });
    }

    // Mengembalikan hasil sebagai JSON
    if ("success" in results[0][0].result) {
      res.json(results[0][0].result); // Hasil dari prosedur biasanya ada di results[0]
    } else {
      res.status(500).json({ error: 'Database query failed' });
    }
  });
});

// Rute untuk menerima request POST Create data
app.put('/api/v1/data', (req, res) => {
  const { pn, data } = req.body; // Mengambil p, d dari body
  
  // Memanggil prosedur yang sesuai
  const sql = `CALL ${pn}(${mysql.escape(JSON.stringify(data))})`;

  db.query(sql, (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      return res.status(500).json({ error: 'Database query failed' });
    }

    // Mengembalikan hasil sebagai JSON
    if ("success" in results[0][0].result) {
      res.json(results[0][0].result); // Hasil dari prosedur biasanya ada di results[0]
    } else {
      res.status(500).json({ error: 'Database query failed' });
    }
  });
});



// Rute untuk menerima request POST Create data
app.patch('/api/v1/data', (req, res) => {
  const { pn, data } = req.body; // Mengambil p, d dari body
  
  // Memanggil prosedur yang sesuai
  const sql = `CALL ${pn}(${mysql.escape(JSON.stringify(data))})`;

  db.query(sql, (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      return res.status(500).json({ error: 'Database query failed' });
    }

    // Mengembalikan hasil sebagai JSON
    if ("success" in results[0][0].result) {
      res.json(results[0][0].result); // Hasil dari prosedur biasanya ada di results[0]
    } else {
      res.status(500).json({ error: 'Database query failed' });
    }
  });
});

// Rute untuk menerima request DELETE
app.delete('/api/v1/data', (req, res) => {
  const { pn, data } = req.body; // Mengambil p, d dari body
  
  // Memanggil prosedur yang sesuai
  const sql = `CALL ${pn}(${mysql.escape(JSON.stringify(data))})`;

  db.query(sql, (error, results) => {
    if (error) {
      console.error('Error executing query:', error);
      return res.status(500).json({ error: 'Database query failed' });
    }

    // Mengembalikan hasil sebagai JSON
    if ("success" in results[0][0].result) {
      res.json(results[0][0].result); // Hasil dari prosedur biasanya ada di results[0]
    } else {
      res.status(500).json({ error: 'Database query failed' });
    }
  });
});

// Mulai server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on http://0.0.0.0:${PORT}`);
});