const db = require('../config/database');

// --- BUAT BOOKING BARU (Untuk Pelanggan) ---
exports.createBooking = (req, res) => {
    // Ambil user_id dari tiket/token JWT yang login
    const user_id = req.user.id; 
    const { table_id, tanggal_booking, jam_mulai, jam_selesai } = req.body;

    // 1. Cek apakah meja sudah dibooking di tanggal dan jam yang beririsan
    const checkQuery = `
        SELECT * FROM bookings 
        WHERE table_id = ? 
        AND tanggal_booking = ? 
        AND status != 'dibatalkan'
        AND (jam_mulai < ? AND jam_selesai > ?)
    `;

    db.query(checkQuery, [table_id, tanggal_booking, jam_selesai, jam_mulai], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        // Jika hasilnya ada (> 0), berarti meja sudah dibooking orang lain!
        if (results.length > 0) {
            return res.status(400).json({ message: 'Maaf, meja ini sudah dibooking pada jam tersebut. Silakan pilih jam atau meja lain.' });
        }

        // 2. Jika meja kosong, buat Kode Unik untuk QR Code (Contoh: BK-168123456)
        const qr_code = 'BK-' + Date.now();

        // 3. Simpan data booking ke database
        const insertQuery = `
            INSERT INTO bookings (user_id, table_id, tanggal_booking, jam_mulai, jam_selesai, qr_code) 
            VALUES (?, ?, ?, ?, ?, ?)
        `;

        db.query(insertQuery, [user_id, table_id, tanggal_booking, jam_mulai, jam_selesai, qr_code], (err, result) => {
            if (err) return res.status(500).json({ error: err.message });
            
            res.status(201).json({ 
                message: 'Booking berhasil! Silakan selesaikan pembayaran.',
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
    // Gabungkan 3 tabel: bookings, users (buat tahu nama pelanggan), dan tables (nomor meja)
    const query = `
        SELECT b.*, u.nama AS nama_pelanggan, t.nomor_meja 
        FROM bookings b
        JOIN users u ON b.user_id = u.id
        JOIN tables t ON b.table_id = t.id
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