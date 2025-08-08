const express = require('express');
const router = express.Router();
const pool = require('../db');
const verifyFirebaseToken = require('../middleware/authMiddleware'); // ✅ Import middleware

// POST /api/drivers/register
router.post('/register', async (req, res) => {
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

// GET /api/drivers/profile
router.get('/profile', verifyFirebaseToken, async (req, res) => {
  try {
    const firebase_uid = req.user.uid; // UID comes from our verified token

    const query = 'SELECT * FROM drivers WHERE firebase_uid = $1';
    const result = await pool.query(query, [firebase_uid]);

    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]); // Send profile data
    } else {
      res.status(404).json({ error: 'Driver profile not found.' });
    }
  } catch (err) {
    console.error('Error fetching driver profile:', err);
    res.status(500).json({ error: 'Failed to fetch driver profile.' });
  }
});


// ✅ NEW: PATCH /api/drivers/profile
// Protected route for a driver to update their own profile.
router.patch('/profile', verifyFirebaseToken, async (req, res) => {
    const firebase_uid = req.user.uid;
    const { name, phone, address, car_reg_number, car_type, license_number, license_expiry } = req.body;

    // Build the query dynamically based on the fields provided
    const fieldsToUpdate = [];
    const values = [];
    let queryIndex = 1;

    // Helper to add fields to the update query
    const addField = (field, value) => {
        if (value) {
            fieldsToUpdate.push(`${field} = $${queryIndex++}`);
            values.push(value);
        }
    };

    addField('name', name);
    addField('phone', phone);
    addField('address', address);
    addField('car_reg_number', car_reg_number);
    addField('car_type', car_type);
    addField('license_number', license_number);
    addField('license_expiry', license_expiry);

    if (fieldsToUpdate.length === 0) {
        return res.status(400).json({ error: 'No fields to update provided.' });
    }

    values.push(firebase_uid); // For the WHERE clause

    const query = `UPDATE drivers SET ${fieldsToUpdate.join(', ')} WHERE firebase_uid = $${queryIndex} RETURNING *;`;

    try {
        const result = await pool.query(query, values);

        if (result.rows.length > 0) {
            res.status(200).json({ message: 'Profile updated successfully', driver: result.rows[0] });
        } else {
            res.status(404).json({ error: 'Driver profile not found.' });
        }
    } catch (err) {
        console.error('Error updating driver profile:', err);
        res.status(500).json({ error: 'Failed to update profile.' });
    }
});


module.exports = router;
