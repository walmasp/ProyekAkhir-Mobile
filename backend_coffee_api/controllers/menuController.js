const db = require('../config/database');

// --- TAMPILKAN SEMUA MENU (Untuk Pelanggan & Admin) ---
exports.getAllMenus = (req, res) => {
    const query = 'SELECT * FROM menus';
    
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({
            message: 'Berhasil mengambil data menu',
            data: results
        });
    });
};

// --- TAMBAH MENU BARU (Untuk Admin) ---
exports.addMenu = (req, res) => {
    // Sesuai dengan kolom di database coffeeshop kamu
    const { nama_menu, deskripsi, harga, kategori, stok_tersedia, foto_url } = req.body;

    const query = 'INSERT INTO menus (nama_menu, deskripsi, harga, kategori, stok_tersedia, foto_url) VALUES (?, ?, ?, ?, ?, ?)';
    
    // stok_tersedia kita set default 1 (true) kalau tidak diisi
    const stok = stok_tersedia !== undefined ? stok_tersedia : 1;

    db.query(query, [nama_menu, deskripsi, harga, kategori, stok, foto_url], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ 
            message: 'Menu baru berhasil ditambahkan!',
            menuId: result.insertId 
        });
    });
};