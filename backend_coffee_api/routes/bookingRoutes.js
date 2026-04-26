const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const authMiddleware = require('../middlewares/authMiddleware');

// ==========================================
// URL UNTUK PELANGGAN
// ==========================================
router.post('/', authMiddleware.verifyToken, bookingController.createBooking);
router.get('/my-bookings', authMiddleware.verifyToken, bookingController.getMyBookings);

// ==========================================
// URL UNTUK ADMIN / KASIR
// ==========================================
// 1. Lihat semua booking (Wajib Admin)
router.get('/admin/all', authMiddleware.verifyToken, authMiddleware.isAdmin, bookingController.getAllBookings);

// 2. Update status booking (Wajib Admin) - ':id' adalah angka ID bookingnya
router.put('/admin/status/:id', authMiddleware.verifyToken, authMiddleware.isAdmin, bookingController.updateBookingStatus);

// 3. Scan QR Code dari pelanggan (Wajib Admin)
router.post('/admin/scan', authMiddleware.verifyToken, authMiddleware.isAdmin, bookingController.scanQRCode);

module.exports = router;