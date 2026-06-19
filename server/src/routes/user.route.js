const express = require("express");

const {
  getMyProfile,
  getUserProfileById,
  updateProfile,
  getAllUsers,
  getUserById,
  deleteUserById,
} = require("../controller/user.controller");
const auth = require("../middleware/auth");
const uploadMiddleware = require("../middleware/upload");
const router = express.Router();
router.get("/me", auth, getMyProfile);
router.get("/me/:userId", auth, getUserProfileById);
router.put("/me", auth, uploadMiddleware.single("avatar"), updateProfile);
router.get("/", auth, getAllUsers);
router.get("/:id", auth, getUserById);
router.delete("/:id", auth, deleteUserById);

module.exports = router;