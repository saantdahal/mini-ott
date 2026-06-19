const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class DeviceSessions extends Model {}

DeviceSessions.init(
  {
    device_session_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    device_type: {
      type: DataTypes.STRING(30),
      allowNull: false,
    },
    device_name: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    os_name: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    browser_name: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    ip_address: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    login_method: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "email",
    },
    access_token_hash: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    refresh_token_hash: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    last_active_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    expires_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    is_current: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    status: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "active",
    },
  },
  {
    sequelize: postgres,
    modelName: "device_sessions",
    tableName: "device_sessions",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { fields: ["user_id"] },
      { fields: ["status"] },
      { fields: ["last_active_at"] },
    ],
  },
);

module.exports = DeviceSessions;
