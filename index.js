// const app = require('./app');
// const db = require('./config/db')
// const UserModel = require('./model/user.model')


// const port = 3000;

// app.get('/',(req,res)=> {
//     res.send("Hello world!!!!!!")
// });

// app.listen(port, ()=>{
//     console.log(`Server is running on port http://localhost:${port}`);
// });

const app = require('./app');
const db = require('./config/db');
const UserModel = require('./model/user.model');

const port = 3000;

app.get('/', (req, res) => {
    res.send("Server is running!");
});

// Global error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        status: false,
        error: err.message || 'Internal Server Error'
    });
});

app.listen(port, '0.0.0.0', () => {
    console.log(`Server is running on port http://localhost:${port}`);
});