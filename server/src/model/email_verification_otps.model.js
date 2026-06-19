const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class EmailVerificationOtps extends Model {}

EmailVerificationOtps.init(
  {
    otp_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    otp_code: {
      type: DataTypes.STRING(6),
      allowNull: false,
    },
    expires_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
  },
  {
    sequelize: postgres,
    modelName: "email_verification_otps",
    tableName: "email_verification_otps",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { fields: ["email"] },
      { fields: ["user_id"] },
      { fields: ["expires_at"] },
    ],
  }
);

module.exports = EmailVerificationOtps;
