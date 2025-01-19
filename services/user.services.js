// const UserModel = require('../model/user.model')

// class UserService{
//     static async registerUser(username, email, password){
//         try{
//             const createUser = new UserModel({username, email, password});
//             return await createUser.save();
//         }catch(err){
//             throw err;
//         }
//     }
// }

// module.exports = UserService;

const UserModel = require('../model/user.model')
const jwt = require('jsonwebtoken');

class UserService {
    static async registerUser(username, email, password) {
        try {
            const existingUser = await UserModel.findOne({ email });
            if (existingUser) {
                throw new Error('Email already registered');
            }

            const createUser = new UserModel({ username, email, password });
            const savedUser = await createUser.save();
            console.log('User saved successfully:', savedUser);
            return savedUser;
        } catch (err) {
            console.error('Error in registerUser service:', err);
            throw err;
        }
    }

    static async loginUser(email) {
        try {
            return await UserModel.findOne({ email });
        } catch (error) {
            throw error;
        }
    }

    static async generateToken(tokenData, secretKey, jwt_expire) {
        return jwt.sign(tokenData, secretKey, { expiresIn: jwt_expire });
    }
}

module.exports = UserService;