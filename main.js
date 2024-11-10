const express = require("express");
const mysql = require("mysql2");
const bodyParser = require("body-parser");
require("dotenv").config();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const app = express();
const port = 3000;

app.use(bodyParser.json());

// MySQL connection
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: process.env.DB_PASSWORD,
  database: "ONLINE_STORE",
});

db.connect((err) => {
  if (err) {
    console.error("Error connecting to the database:", err);
    return;
  }
  console.log("Connected to the MySQL database.");
});
//get all users
app.get("/user/", (req, res) => {
  const query = "SELECT * FROM USER";
  db.query(query, (err, results) => {
    if (err) {
      console.error("Error fetching pets:", err);
      res.status(500).send("Server error");
      return;
    }
    console.log(results);

    res.status(200).json(results);
  });
});

app.get("/user/:userID", (req, res) => {
  const { userID } = req.params;
  const query = "SELECT * FROM USER WHERE ID = ?";
  db.query(query, [userID], (err, results) => {
    if (err) {
      console.error("Error fetching pets:", err);
      res.status(500).send("Server error");
      return;
    }
    console.log(results);

    res.status(200).json(results);
  });
});

// Register
app.post("/register", (req, res) => {
  const { username, password, address } = req.body;

  // Check if the user already exists
  const checkUserQuery = "SELECT * FROM USER WHERE USERNAME = ?";
  db.query(checkUserQuery, [username], (err, results) => {
    if (err) {
      console.error("Error checking user:", err);
      res.status(500).send("Server error");
      return;
    }

    if (results.length > 0) {
      res.status(400).send("Username already exists");
      return;
    }

    // Hash the password
    bcrypt.hash(password, 10, (err, hashedPassword) => {
      if (err) {
        console.error("Error hashing password:", err);
        res.status(500).send("Server error");
        return;
      }

      // Insert the new user into the database
      const insertUserQuery =
        "INSERT INTO USER (USERNAME, PASSWORD, ADDRESS) VALUES (?, ?, ?)";
      db.query(
        insertUserQuery,
        [username, hashedPassword, address],
        (err, results) => {
          if (err) {
            console.error("Error inserting user:", err);
            res.status(500).send("Server error");
            return;
          }

          res.status(201).send("User registered successfully");
        }
      );
    });
  });
});

// Login
app.post("/login", (req, res) => {
  const { username, password } = req.body;
  const query = "SELECT * FROM USER WHERE USERNAME = ?";

  db.query(query, [username], (err, results) => {
    if (err) {
      console.error("Error fetching user:", err);
      res.status(500).send("Server error");
      return;
    }

    if (results.length === 0) {
      res.status(401).send("Invalid username or password");
      return;
    }

    const user = results[0];

    // Compare the provided password with the stored hash
    bcrypt.compare(password, user.PASSWORD, (err, isMatch) => {
      if (err) {
        console.error("Error comparing passwords:", err);
        res.status(500).send("Server error");
        return;
      }

      if (!isMatch) {
        res.status(401).send("Invalid username or password");
        return;
      }

      // Generate a JWT token
      const token = jwt.sign({ id: user.ID }, process.env.JWT_SECRET, {
        expiresIn: "1h",
      });

      res.status(200).json({ token });
    });
  });
});

//check product review by product id
app.get("/product/:productID/review", (req, res) => {
  const { productID } = req.params;
  const query = `SELECT 
    p.ID AS id,
    p.NAME AS title,
    p.CATEGORY AS category,
    p.PRICE AS price,
    p.BRAND AS brand,
    p.LIFESTAGE AS lifestage,
    p.IMG AS img,
    p.WEIGHT AS weight,
    p.DESCRIPTION AS description,
    p.INGREDIENTS AS ingredients,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'id', pr.ID,
            'username', u.USERNAME,
            'comment', pr.COMMENT,
            'date', pr.CREATE_DATE
        )
    ) AS reviews
FROM 
    PRODUCT p
JOIN 
    PRODUCT_REVIEW pr ON p.ID = pr.PRODUCT_ID
JOIN 
    USER u ON pr.USER_ID = u.ID
WHERE 
    p.ID = ?
GROUP BY 
    p.ID;`;
  db.query(query, [productID], (err, results) => {
    if (err) {
      console.error("Error fetching pets:", err);
      res.status(500).send("Server error");
      return;
    }
    console.log(results);

    res.status(200).json(results);
  });
});

app.listen(port, () => {
  console.log(`Server running on port http://localhost:${port}`);
});
