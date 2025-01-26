// const UserService = require('../services/user.services');
// const userService = require('../services/user.services')


// // for frontend
// exports.register = async(req, res, next)=>{
//     try{
//         const {username, email, password} = req.body;

//         const successRes = await UserService.registerUser(username, email, password);

//         res.json({status: true, success:"User Registered Successfully"});
//     }
//     catch (error) {
//         throw error
//     }
// }

const UserService = require('../services/user.services');

exports.register = async(req, res, next) => {
    try {
        console.log('Received registration request:', req.body);
        const { username, email, password } = req.body;

        if (!username || !email || !password) {
            console.log('Missing required fields');
            return res.status(400).json({
                status: false,
                error: "All fields are required"
            });
        }

        const successRes = await UserService.registerUser(username, email, password);
        console.log('Registration successful:', successRes);

        res.json({
            status: true,
            success: "User Registered Successfully"
        });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({
            status: false,
            error: error.message || "Registration failed"
        });
    }
}

exports.login = async(req, res, next) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                status: false,
                error: "Email and password are required"
            });
        }

        const user = await UserService.loginUser(email);

        if (!user) {
            return res.status(404).json({
                status: false,
                error: 'User does not exist'
            });
        }

        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            return res.status(401).json({
                status: false,
                error: 'Invalid Password'
            });
        }

        let tokenData = {_id: user._id, email: user.email};
        const token = await UserService.generateToken(tokenData, "secretKey", '1h');

        res.status(200).json({
            status: true, 
            token: token
        });

    } catch (error) {
        console.error('Login error:', error);
        return res.status(500).json({
            status: false,
            error: error.message || "Login failed"
        });
    }
};

exports.validateToken = async (req, res) => {
    try {
        const token = req.headers.authorization.split(' ')[1];
        // Verify token logic
        jwt.verify(token, 'secretKey');
        res.json({ valid: true });
    } catch (error) {
        res.json({ valid: false });
    }
};