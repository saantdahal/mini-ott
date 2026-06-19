const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class Episodes extends Model {}

Episodes.init(
  {
    episode_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    content_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    season_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    episode_number: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    slug: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    short_description: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    thumbnail_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    banner_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    video_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    stream_manifest_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    subtitle_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    duration_seconds: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    release_date: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    access_type: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "free",
    },
    required_coins: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    view_count: {
      type: DataTypes.BIGINT,
      allowNull: false,
      defaultValue: 0,
    },
    status: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "draft",
    },
  },
  {
    sequelize: postgres,
    modelName: "episodes",
    tableName: "episodes",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { unique: true, fields: ["season_id", "episode_number"] },
      { fields: ["content_id"] },
      { fields: ["season_id"] },
      { fields: ["release_date"] },
    ],
  },
);

module.exports = Episodes;
