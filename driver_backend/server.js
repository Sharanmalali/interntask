const express = require('express');
const cors = require('cors');
require('dotenv').config();

const driverRoutes = require('./routes/driverRoutes');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/drivers', driverRoutes);

const PORT = process.env.PORT || 3000;

// ✅ Listen on all network interfaces so other devices can access it
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

