const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class ContentGenres extends Model {}

ContentGenres.init(
  {
    content_genre_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    content_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    genre_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
  },
  {
    sequelize: postgres,
    modelName: "content_genres",
    tableName: "content_genres",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: false,
    indexes: [
      { unique: true, fields: ["content_id", "genre_id"] },
      { fields: ["genre_id"] },
    ],
  },
);

module.exports = ContentGenres;
