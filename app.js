// const express = require('express');
// const body_parser = require('body-parser');// to check whatever data comes from the body of req.body
// const userRouter = require('./routers/user.router');

// const app = express();
// app.use(body_parser.json());
// app.use('/', userRouter);

// module.exports = app;

const express = require('express');
const body_parser = require('body-parser');
const userRouter = require('./routers/user.router');

const app = express();

// Add CORS middleware
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    if (req.method === 'OPTIONS') {
        return res.sendStatus(200);
    }
    next();
});

app.use(body_parser.json());
app.use('/api/user', userRouter);

module.exports = app;