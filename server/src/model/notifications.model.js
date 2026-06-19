const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class Notifications extends Model {}

Notifications.init(
  {
    notification_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    message: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    notification_type: {
      type: DataTypes.STRING(50),
      allowNull: false,
    },
    related_entity_type: {
      type: DataTypes.STRING(50),
      allowNull: true,
    },
    related_entity_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    is_read: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    sent_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    read_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    sequelize: postgres,
    modelName: "notifications",
    tableName: "notifications",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: false,
    indexes: [
      { fields: ["user_id"] },
      { fields: ["notification_type"] },
      { fields: ["is_read"] },
      { fields: ["created_at"] },
    ],
  },
);

module.exports = Notifications;
