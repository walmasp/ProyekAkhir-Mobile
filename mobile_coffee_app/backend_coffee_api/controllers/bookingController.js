const db = require('../config/database');

// --- BUAT BOOKING BARU (Untuk Pelanggan) ---
exports.createBooking = (req, res) => {
    const user_id = req.user.id; 
    // Tambahan: kita menerima cafe_id dari Flutter
    const { cafe_id, table_id, tanggal_booking, jam_mulai, jam_selesai } = req.body;

    const checkQuery = `
        SELECT * FROM bookings 
        WHERE table_id = ? 
        AND tanggal_booking = ? 
        AND status != 'dibatalkan'
        AND (jam_mulai < ? AND jam_selesai > ?)
    `;

    db.query(checkQuery, [table_id, tanggal_booking, jam_selesai, jam_mulai], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        if (results.length > 0) {
            return res.status(400).json({ message: 'Maaf, meja ini sudah dibooking pada jam tersebut.' });
        }

        const qr_code = 'BK-' + Date.now();

        // Tambahkan cafe_id di query INSERT
        const insertQuery = `
            INSERT INTO bookings (user_id, cafe_id, table_id, tanggal_booking, jam_mulai, jam_selesai, qr_code) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
        `;

        db.query(insertQuery, [user_id, cafe_id, table_id, tanggal_booking, jam_mulai, jam_selesai, qr_code], (err, result) => {
            if (err) return res.status(500).json({ error: err.message });
            
            res.status(201).json({ 
                message: 'Booking berhasil!',
                booking_id: result.insertId,
                qr_code: qr_code
            });
        });
    });
};

// --- LIHAT RIWAYAT BOOKING SAYA (Untuk Pelanggan) ---
exports.getMyBookings = (req, res) => {
    const user_id = req.user.id;
    
    // Kita gabungkan (JOIN) tabel bookings dengan tabel tables biar dapat nomor mejanya
    const query = `
        SELECT b.*, t.nomor_meja, t.area 
        FROM bookings b
        JOIN tables t ON b.table_id = t.id
        WHERE b.user_id = ?
        ORDER BY b.tanggal_booking DESC, b.jam_mulai DESC
    `;

    db.query(query, [user_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({
            message: 'Berhasil mengambil riwayat booking',
            data: results
        });
    });
};

// ==========================================
// --- FITUR KHUSUS ADMIN & KASIR ---
// ==========================================

// --- LIHAT SEMUA BOOKING (Hari ini / Semua) ---
exports.getAllBookings = (req, res) => {
    // Tambahkan JOIN ke tabel cafe biar admin tau ini pesanan cafe mana
    const query = `
        SELECT b.*, u.nama AS nama_pelanggan, t.nomor_meja, c.nama_cafe 
        FROM bookings b
        JOIN users u ON b.user_id = u.id
        JOIN tables t ON b.table_id = t.id
        JOIN cafe c ON b.cafe_id = c.id
        ORDER BY b.tanggal_booking DESC, b.jam_mulai ASC
    `;

    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({
            message: 'Berhasil mengambil semua data booking',
            data: results
        });
    });
};

// --- UBAH STATUS BOOKING (Approve / Reject) ---
exports.updateBookingStatus = (req, res) => {
    const booking_id = req.params.id; // Ambil ID dari URL
    const { status } = req.body; // Status baru: 'confirmed', 'dibatalkan', dll

    const query = 'UPDATE bookings SET status = ? WHERE id = ?';
    
    db.query(query, [status, booking_id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Data booking tidak ditemukan!' });
        }
        
        res.status(200).json({ message: `Status booking berhasil diubah menjadi: ${status}` });
    });
};

// --- SCAN QR CODE TIKET (Check-in Pelanggan) ---
exports.scanQRCode = (req, res) => {
    const { qr_code } = req.body;

    // 1. Cari data booking berdasarkan QR Code
    const query = 'SELECT * FROM bookings WHERE qr_code = ?';
    
    db.query(query, [qr_code], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        
        if (results.length === 0) {
            return res.status(404).json({ message: 'QR Code tidak valid atau tidak ditemukan!' });
        }

        const booking = results[0];

        // 2. Ubah statusnya menjadi 'selesai' (tandanya orangnya sudah datang dan nongkrong)
        const updateQuery = 'UPDATE bookings SET status = "selesai" WHERE id = ?';
        db.query(updateQuery, [booking.id], (err, updateResult) => {
            if (err) return res.status(500).json({ error: err.message });
            
            res.status(200).json({ 
                message: 'Scan QR berhasil! Pelanggan telah check-in.',
                booking_data: booking
            });
        });
    });
};