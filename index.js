const app = require('./app');
const db = require('./config/db');
const UserModel = require('./models/user.model');
require('dotenv').config();

const port = process.env.PORT || 3000;

// Basic route to check server status
app.get('/', (req, res) => {
    res.json({
        status: true,
        message: "Server is running!"
    });
});

// Global error handler middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        status: false,
        message: 'Internal Server Error',
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

// Start server
app.listen(port, '0.0.0.0', () => {
    console.log(`Server is running on http://localhost:${port}`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
    console.error('Unhandled Promise Rejection:', err);
    // Optionally, you can choose to exit the process
    // process.exit(1);
});