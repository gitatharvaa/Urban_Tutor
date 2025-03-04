const mongoose = require('mongoose');

const connection = mongoose.createConnection('mongodb://127.0.0.1:27017/UrbanTutor', {
    serverSelectionTimeoutMS: 5000, // Timeout after 5s
    autoIndex: true, // Build indexes
})
.on('open', () => {
    console.log('MongoDB Connected Successfully');
})
.on('error', (err) => {
    console.log('MongoDB Connection Error:', err);
})
.on('disconnected', () => {
    console.log('MongoDB Disconnected');
});

// Handle graceful shutdown
process.on('SIGINT', async () => {
    try {
        await connection.close();
        console.log('MongoDB connection closed through app termination');
        process.exit(0);
    } catch (err) {
        console.error('Error during shutdown:', err);
        process.exit(1);
    }
});

module.exports = connection;