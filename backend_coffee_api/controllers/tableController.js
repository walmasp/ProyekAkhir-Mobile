const db = require('../config/database');

// --- TAMPILKAN SEMUA MEJA (Untuk Pelanggan & Admin) ---
exports.getAllTables = (req, res) => {
    const query = 'SELECT * FROM tables';
    
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({
            message: 'Berhasil mengambil data meja',
            data: results
        });
    });
};

// --- TAMBAH MEJA BARU (Khusus Admin) ---
exports.addTable = (req, res) => {
    const { nomor_meja, kapasitas, area } = req.body;

    const query = 'INSERT INTO tables (nomor_meja, kapasitas, area) VALUES (?, ?, ?)';
    
    db.query(query, [nomor_meja, kapasitas, area], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ 
            message: 'Meja baru berhasil ditambahkan!',
            tableId: result.insertId 
        });
    });
};