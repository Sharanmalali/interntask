const express = require('express');
const cors = require('cors');
require('dotenv').config();

const driverRoutes = require('./routes/driverRoutes');
const customerRoutes = require('./routes/customerRoutes'); // ✅ Import customer routes

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/drivers', driverRoutes);
app.use('/api/customers', customerRoutes); // ✅ Use customer routes

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});