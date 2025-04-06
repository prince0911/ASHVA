const express = require('express');
const router = express.Router();
const User = require('../models/User');

router.post('/add', async (req, res) => {
  try {
    const user = new User(req.body);
    await user.save();
    return res.status(201).json({ message: "User saved successfully ✅" });
  } catch (err) {
    console.error("❌ Error saving user:", err);
    return res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
