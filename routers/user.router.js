const router = require('express').Router();

const UserController = require("../controllers/user.controller");

router.post('/registration',UserController.register);//this is API which is hit by user
            //above is our API name
            router.post('/login', UserController.login); // Add this line
            router.post('/validate-token', UserController.validateToken);

module.exports = router;// we do this, so we can import it in another file.