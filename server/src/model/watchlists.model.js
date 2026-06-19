const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class Watchlists extends Model {}

Watchlists.init(
  {
    watchlist_id: {
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
  },
  {
    sequelize: postgres,
    modelName: "watchlists",
    tableName: "watchlists",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: false,
    indexes: [
      { unique: true, fields: ["user_id", "content_id"] },
      { fields: ["user_id"] },
      { fields: ["content_id"] },
    ],
  },
);

module.exports = Watchlists;
