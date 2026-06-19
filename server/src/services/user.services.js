import User from "../model/user.js";
import bcrypt from "bcryptjs";

export class UserService {
  static async getUserById(userId) {
    const user = await User.findById(userId);
    if (!user) {
      throw new Error("User not found");
    }
    return user;
  }

  static getUserProfileData(user) {
    const {
      password: _,
      otp: __,
      otpExpiry: ___,
      ...userData
    } = user.toObject();
    return userData;
  }

  static async updateUserProfile(userId, updateData) {
    const data = { ...updateData };
    delete data.password; 

    const updatedUser = await User.findByIdAndUpdate(userId, data, { new: true });
    if (!updatedUser) {
      throw new Error("User not found");
    }
    return updatedUser;
  }

  static async updateUserPassword(userId, oldPassword, newPassword) {
    const user = await User.findById(userId);
    if (!user) {
      throw new Error("User not found");
    }

    const isValid = await bcrypt.compare(oldPassword, user.password);
    if (!isValid) {
      throw new Error("Wrong old password");
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await User.findByIdAndUpdate(userId, { password: hashedPassword });

    return true;
  }


  static async getAllUsers() {
    const users = await User.find().select(
      "-password -__v -createdAt -updatedAt -otp -otpExpiry"
    );
    return users;
  }
  static async getUserByIdAdmin(userId) {
    const user = await User.findById(userId).select("-password");
    if (!user) {
      throw new Error("User not found");
    }
    return user;
  }
}