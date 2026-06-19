const Users = require("../model/users.model");
const { uploadImageToCloudinary } = require("../config/cloudinary");

const sanitizeUser = (user) => ({
  user_id: user.user_id,
  full_name: user.full_name,
  email: user.email,
  phone: user.phone,
  auth_provider: user.auth_provider,
  avatar_key: user.avatar_key,
  role: user.role,
  gender: user.gender,
  date_of_birth: user.date_of_birth,
  country: user.country,
  is_email_verified: user.is_email_verified,
  status: user.status,
  last_login_at: user.last_login_at,
  created_at: user.created_at,
  updated_at: user.updated_at,
});

const getUserById = async (userId) => {
  const user = await Users.findByPk(userId);
  if (!user || user.status !== "active") {
    throw new Error("User not found");
  }
  return user;
};

const getMyProfile = async (userId) => {
  const user = await getUserById(userId);
  return sanitizeUser(user);
};

const updateProfile = async (userId, payload, imageFile) => {
  const user = await getUserById(userId);

  const updateData = {
    full_name: payload.full_name || user.full_name,
    phone: payload.phone !== undefined ? payload.phone : user.phone,
    country: payload.country !== undefined ? payload.country : user.country,
    gender: payload.gender !== undefined ? payload.gender : user.gender,
    date_of_birth:
      payload.date_of_birth !== undefined
        ? payload.date_of_birth
        : user.date_of_birth,
  };

  if (imageFile) {
    try {
      const uploadedFile = await uploadImageToCloudinary(
        imageFile.buffer,
        `${Date.now()}-${user.email}`
      );
      updateData.avatar_key = uploadedFile.secure_url;
    } catch (uploadError) {
      throw new Error(`Image upload failed: ${uploadError.message}`);
    }
  }

  await user.update(updateData);

  return sanitizeUser(user);
};

const getAllUsers = async () => {
  const users = await Users.findAll({
    where: { status: "active" },
    attributes: {
      exclude: ["password_hash"],
    },
  });
  return users.map(sanitizeUser);
};

const getUserByIdForAdmin = async (adminId, userId) => {
  const user = await Users.findByPk(userId, {
    attributes: {
      exclude: ["password_hash"],
    },
  });
  if (!user) {
    throw new Error("User not found");
  }
  return user;
};

const deleteUserAccount = async (userId) => {
  const user = await Users.findByPk(userId);
  if (!user) {
    throw new Error("User not found");
  }

  await user.update({ status: "inactive" });
  return {
    user_id: user.user_id,
    email: user.email,
    status: user.status,
  };
};

module.exports = {
  getUserById,
  getMyProfile,
  updateProfile,
  getAllUsers,
  getUserByIdForAdmin,
  deleteUserAccount,
  sanitizeUser,
};
