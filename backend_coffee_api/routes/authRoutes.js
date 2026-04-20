const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Mendaftarkan URL untuk Register dan Login
router.post('/register', authController.register);
router.post('/login', authController.login);

module.exports = router;