const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: String,
  fullName: String,
  email: String,
  contactNo: String,
  emergencyContact: String,
  homeAddress: String,
  gender: String,
  password: String,
  vehicleType: String,
  vehicleModel: String,
  numberPlate: String,
  travelPoints: Number
});

module.exports = mongoose.model('User', userSchema);
