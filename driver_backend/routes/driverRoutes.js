const express = require('express');
const router = express.Router();
const pool = require('../db');
const verifyFirebaseToken = require('../middleware/authMiddleware'); // ✅ Import middleware

// POST /api/drivers/register
// This route does not need token verification since the user might not have a profile yet.
router.post('/register', async (req, res) => {
  // ... (Your existing /register code remains unchanged)
  const {
    name, phone, address, email, carRegNumber,
    carType, licenseNumber, licenseExpiry, firebase_uid,
  } = req.body;

  if (!firebase_uid) {
    return res.status(400).json({ error: 'Firebase UID is required.' });
  }
  try {
    const query = 'INSERT INTO drivers (name, phone, address, email, car_reg_number, car_type, license_number, license_expiry, firebase_uid) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *;';
    const values = [
      name, phone, address, email, carRegNumber,
      carType, licenseNumber, licenseExpiry, firebase_uid,
    ];
    const result = await pool.query(query, values);
    res.status(200).json({ message: 'Driver registered successfully', driver: result.rows[0] });
  } catch (err) {
    console.error(err);
    if (err.code === '23505') {
      return res.status(409).json({ error: 'This user profile already exists.' });
    }
    res.status(500).json({ error: 'Failed to register driver' });
  }
});

// ✅ NEW: GET /api/drivers/profile
// This route IS protected. It will only work if a valid token is sent.
router.get('/profile', verifyFirebaseToken, async (req, res) => {
  try {
    const firebase_uid = req.user.uid; // UID comes from our verified token

    const query = 'SELECT * FROM drivers WHERE firebase_uid = $1';
    const result = await pool.query(query, [firebase_uid]);

    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]); // Send profile data
    } else {
      // This case can happen if the user has an auth account but hasn't completed driver registration
      res.status(404).json({ error: 'Driver profile not found.' });
    }
  } catch (err) {
    console.error('Error fetching driver profile:', err);
    res.status(500).json({ error: 'Failed to fetch driver profile.' });
  }
});

module.exports = router;