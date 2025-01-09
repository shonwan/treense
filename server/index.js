const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(bodyParser.json());
app.use(express.static('web')); // Serve static files (CSS, JS, images) from "web" folder

// Supabase initialization
const supabaseUrl = "https://zjvbmahavecgovtgjkch.supabase.co"; // Replace with your Supabase URL
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqdmJtYWhhdmVjZ292dGdqa2NoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxMDM0MDQsImV4cCI6MjA0ODY3OTQwNH0.s6D59MWDEeEAKUnAco7_RSoLjbkRbivqhJaMmVpttpQ"; // Replace with your API Key
const supabase = createClient(supabaseUrl, supabaseKey);

// Routes
const authRoutes = require('./routes/auth');
app.use('/api/auth', authRoutes);

// Route to serve dashboard.html as the default page
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/web/index.html');
});

// Additional route examples for other HTML files
app.get('/analytics', (req, res) => {
  res.sendFile(__dirname + '/web/views/analytics.html');
});

app.get('/dashboard', (req, res) => {
  res.sendFile(__dirname + '/web/views/dashboard.html');
});

app.get('/history', (req, res) => {
  res.sendFile(__dirname + '/web/views/history.html');
});

app.get('/signup', (req, res) => {
  res.sendFile(__dirname + '/web/views/signup.html');
});

app.get('/profile', (req, res) => {
  res.sendFile(__dirname + '/web/views/settings.html');
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
