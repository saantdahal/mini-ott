const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class Contents extends Model {}

Contents.init(
  {
    content_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    slug: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    short_description: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    content_type: {
      type: DataTypes.STRING(50),
      allowNull: false,
    },
    is_series: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    language: {
      type: DataTypes.STRING(50),
      allowNull: true,
    },
    country: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    age_rating: {
      type: DataTypes.STRING(20),
      allowNull: true,
    },
    release_date: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    duration_seconds: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    total_seasons: {
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: 0,
    },
    total_episodes: {
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: 0,
    },
    thumbnail_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    poster_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    banner_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    trailer_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    stream_manifest_key: {
      type: DataTypes.STRING(500),
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
    seo_title: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    seo_description: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    status: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "draft",
    },
    published_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    created_by: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    updated_by: {
      type: DataTypes.UUID,
      allowNull: true,
    },
  },
  {
    sequelize: postgres,
    modelName: "contents",
    tableName: "contents",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { unique: true, fields: ["slug"] },
      { fields: ["content_type"] },
      { fields: ["status"] },
      { fields: ["release_date"] },
      { fields: ["access_type"] },
    ],
  },
);

module.exports = Contents;
