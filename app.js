const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');
const userRouter = require('./routers/user.router');
const noteRouter = require('./routers/note.router');

const app = express();

// Use cors middleware instead of custom implementation
app.use(cors({
    origin: '*', // In production, replace with specific origin
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Origin', 'X-Requested-With', 'Content-Type', 'Accept', 'Authorization']
}));

// Middleware for parsing JSON and url-encoded data
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '50mb' }));

// Serve static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// API routes
app.use('/api/user', userRouter);
app.use('/api/notes', noteRouter);

// 404 handler
app.use((req, res, next) => {
    res.status(404).json({
        status: false,
        message: 'Route not found'
    });
});

module.exports = app;