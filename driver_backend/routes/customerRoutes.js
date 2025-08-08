const express = require('express');
const router = express.Router();
const pool = require('../db');
const verifyFirebaseToken = require('../middleware/authMiddleware');

// All customer routes are protected
router.use(verifyFirebaseToken);

// GET /api/customers/profile
// Fetches the profile for the logged-in customer.
router.get('/profile', async (req, res) => {
  try {
    const firebase_uid = req.user.uid;
    const query = 'SELECT * FROM customers WHERE firebase_uid = $1';
    const result = await pool.query(query, [firebase_uid]);

    if (result.rows.length > 0) {
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ error: 'Customer profile not found.' });
    }
  } catch (err) {
    console.error('Error fetching customer profile:', err);
    res.status(500).json({ error: 'Failed to fetch customer profile.' });
  }
});

// POST /api/customers/profile
// Creates a new profile for the logged-in customer.
router.post('/profile', async (req, res) => {
  const { name, phone } = req.body;
  const { email, uid: firebase_uid } = req.user; // Get email and UID from verified token

  if (!name || !phone) {
    return res.status(400).json({ error: 'Name and phone are required.' });
  }

  try {
    const query = 'INSERT INTO customers (name, phone, email, firebase_uid) VALUES ($1, $2, $3, $4) RETURNING *;';
    const values = [name, phone, email, firebase_uid];
    const result = await pool.query(query, values);
    res.status(201).json({ message: 'Profile created successfully', customer: result.rows[0] });
  } catch (err) {
    console.error(err);
    if (err.code === '23505') { // unique_violation
      return res.status(409).json({ error: 'A profile for this user already exists.' });
    }
    res.status(500).json({ error: 'Failed to create profile.' });
  }
});

// PATCH /api/customers/profile
// Updates the profile for the logged-in customer.
router.patch('/profile', async (req, res) => {
    const firebase_uid = req.user.uid;
    const { name, phone } = req.body;

    // For this simple profile, we'll update both fields.
    if (!name || !phone) {
        return res.status(400).json({ error: 'Name and phone are required for an update.' });
    }

    try {
        const query = `UPDATE customers SET name = $1, phone = $2 WHERE firebase_uid = $3 RETURNING *;`;
        const values = [name, phone, firebase_uid];
        const result = await pool.query(query, values);

        if (result.rows.length > 0) {
            res.status(200).json({ message: 'Profile updated successfully', customer: result.rows[0] });
        } else {
            res.status(404).json({ error: 'Customer profile not found.' });
        }
    } catch (err) {
        console.error('Error updating customer profile:', err);
        res.status(500).json({ error: 'Failed to update profile.' });
    }
});

module.exports = router;
