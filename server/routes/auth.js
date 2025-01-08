const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { createClient } = require("@supabase/supabase-js");
const authenticateToken = require("../middlewares/authenticaToken");  // Import the authentication middleware

const router = express.Router();

// Supabase setup
const supabaseUrl = "https://zjvbmahavecgovtgjkch.supabase.co"; // Replace with your Supabase URL
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqdmJtYWhhdmVjZ292dGdqa2NoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxMDM0MDQsImV4cCI6MjA0ODY3OTQwNH0.s6D59MWDEeEAKUnAco7_RSoLjbkRbivqhJaMmVpttpQ"; // Replace with your API Key
const supabase = createClient(supabaseUrl, supabaseKey);

/**
 * User Signup Route
 */
router.post("/signup", async (req, res) => {
  const { firstName, lastName, email, password } = req.body;

  try {
    // Check if the user already exists
    const { data: existingUser, error: checkError } = await supabase
      .from("users")
      .select("*")
      .eq("email", email)
      .single();

    if (existingUser) {
      return res.status(400).json({ message: "Email is already registered" });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert new user
    const { data, error } = await supabase.from("users").insert([
      {
        first_name: firstName,
        last_name: lastName,
        email: email,
        password: hashedPassword,
      },
    ]);

    if (error) throw error;

    res.status(201).json({ message: "User created successfully" });
  } catch (err) {
    res
      .status(500)
      .json({ message: "Error creating user", error: err.message });
  }
});


/**
 * User Login Route
 */
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    // Check if the user exists
    const { data: user, error } = await supabase
      .from("users")
      .select("*")
      .eq("email", email)
      .single();

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Verify password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    res.status(200).json({ message: "Login successful", user });
  } catch (err) {
    res.status(500).json({ message: "Error logging in", error: err.message });
  }
});
/**
 * User Profile Route (With Authentication Middleware)
 */
router.get("/profile", authenticateToken, async (req, res) => {
  try {
      const user = req.user;  // Get the authenticated user from the request object
      if (!user) {
          return res.status(401).json({ error: 'User not authenticated' });
      }

      // Fetch user data from the Supabase database
      const { data, error } = await supabase
          .from('users')
          .select('first_name, last_name, email')
          .eq('id', user.id)
          .single();

      if (error) {
          throw error;
      }

      // Send the user data as response
      res.json(data);
  } catch (error) {
      console.error("Error fetching user profile", error);
      res.status(500).send("Error fetching user profile");
  }
});

/**
 * Plant Classifications Route
 */
router.get("/classifications", async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("plant_classifications")
      .select("*");
    if (error) {
      throw error;
    }
    res.json(data);
  } catch (error) {
    console.error("Error fetching classifications", error);
    res.status(500).send("Error fetching classifications");
  }
});

/**
 * Summary Route
 */
router.get("/summary", async (req, res) => {
  try {
    const { data: totalCountData, error: totalCountError } = await supabase
      .from("plant_classifications")
      .select("*", { count: "exact" });
    const { data: healthyCountData, error: healthyCountError } = await supabase
      .from("plant_classifications")
      .select("*", { count: "exact" })
      .eq("classification", "Healthy");
    const { data: unhealthyCountData, error: unhealthyCountError } =
      await supabase
        .from("plant_classifications")
        .select("*", { count: "exact" })
        .eq("classification", "Unhealthy");
    if (totalCountError || healthyCountError || unhealthyCountError) {
      throw new Error("Error fetching summary data");
    }
    const summary = {
      total: totalCountData.length,
      healthy: healthyCountData.length,
      unhealthy: unhealthyCountData.length,
    };
    res.json(summary);
  } catch (error) {
    console.error("Error fetching summary", error);
    res.status(500).send("Error fetching summary");
  }
});

/**
 * Recent Uploads Route
 */
router.get("/recent-uploads", async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("plant_classifications")
      .select("image_url, classification, created_at")
      .order("created_at", { ascending: false })  // Sort by most recent uploads first
      .limit(5);  // Fetch the 5 most recent uploads (you can adjust this number)

    if (error) throw error;

    res.json(data);  // Send the data to the frontend
  } catch (error) {
    console.error("Error fetching recent uploads", error);
    res.status(500).send("Error fetching recent uploads");
  }
});

module.exports = router;
