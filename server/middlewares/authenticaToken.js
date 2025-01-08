// authenticateToken.js
const jwt = require("jsonwebtoken");

function authenticateToken(req, res, next) {
    const token = req.headers["authorization"]?.split(" ")[1]; // Extract token from "Bearer <token>"

    if (!token) {
        return res.status(401).json({ error: "Authentication token is required" });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: "Invalid token" });
        }

        req.user = user;  // Store user information in the request object
        next();  // Proceed to the next middleware or route handler
    });
}

module.exports = authenticateToken;
