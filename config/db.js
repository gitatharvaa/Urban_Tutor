// const mongoose = require('mongoose');

// //to get connected to mongodb database.
// const connection = mongoose.createConnection('mongodb://127.0.0.1:27017/UrbanTutor').on('open', ()=> {
//     console.log('MongoDb connected');
// }).on('error', () =>{
//     console.log('MongoDb connection error');
// });

// module.exports = connection;

const mongoose = require('mongoose');

const connection = mongoose.createConnection('mongodb://127.0.0.1:27017/UrbanTutor')
.on('open', () => {
    console.log('MongoDB Connected Successfully');
})
.on('error', (err) => {
    console.log('MongoDB Connection Error:', err);
});

// Add connection error handler
connection.on('disconnected', () => {
    console.log('MongoDB Disconnected');
});

process.on('SIGINT', async () => {
    await connection.close();
    process.exit(0);
});

module.exports = connection;