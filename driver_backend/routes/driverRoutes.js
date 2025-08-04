// routes/driverRoutes.js
const express = require('express');
const router = express.Router();
const pool = require('../db');

router.post('/register', async (req, res) => {
  const {
    name,
    phone,
    address,
    email,
    carRegNumber,
    carType,
    licenseNumber,
    licenseExpiry,
  } = req.body;

  try {
    const query = `
      INSERT INTO drivers 
        (name, phone, address, email, car_reg_number, car_type, license_number, license_expiry)
      VALUES
        ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *;
    `;

    const values = [
      name,
      phone,
      address,
      email,
      carRegNumber,
      carType,
      licenseNumber,
      licenseExpiry,
    ];

    const result = await pool.query(query, values);
    res.status(200).json({ message: 'Driver registered successfully', driver: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to register driver' });
  }
});

module.exports = router;
