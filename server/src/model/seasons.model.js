const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class Seasons extends Model {}

Seasons.init(
  {
    season_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    content_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    season_number: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    thumbnail_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    trailer_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    release_date: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    status: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "draft",
    },
  },
  {
    sequelize: postgres,
    modelName: "seasons",
    tableName: "seasons",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { unique: true, fields: ["content_id", "season_number"] },
      { fields: ["content_id"] },
    ],
  },
);

module.exports = Seasons;
