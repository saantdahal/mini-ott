const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class WatchHistory extends Model {}

WatchHistory.init(
  {
    watch_history_id: {
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
      allowNull: false,
    },
    episode_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    watched_seconds: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    total_duration_seconds: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    progress_percent: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: false,
      defaultValue: 0,
    },
    is_completed: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    last_watched_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
  },
  {
    sequelize: postgres,
    modelName: "watch_history",
    tableName: "watch_history",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { fields: ["user_id"] },
      { fields: ["content_id"] },
      { fields: ["episode_id"] },
      { fields: ["last_watched_at"] },
      { unique: true, fields: ["user_id", "content_id", "episode_id"] },
    ],
  },
);

module.exports = WatchHistory;
