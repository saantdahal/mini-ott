const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class UserContentAccess extends Model {}

UserContentAccess.init(
  {
    user_content_access_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    content_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    episode_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    access_type: {
      type: DataTypes.STRING(30),
      allowNull: false,
    },
    source_payment_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    source_wallet_transaction_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    granted_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    expires_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    status: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "active",
    },
  },
  {
    sequelize: postgres,
    modelName: "user_content_access",
    tableName: "user_content_access",
    timestamps: false,
    underscored: true,
    indexes: [
      { fields: ["user_id"] },
      { fields: ["content_id"] },
      { fields: ["episode_id"] },
      { fields: ["status"] },
    ],
  },
);

module.exports = UserContentAccess;
