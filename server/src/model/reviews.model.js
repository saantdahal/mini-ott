const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class Reviews extends Model {}

Reviews.init(
  {
    review_id: {
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
    rating: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    review_text: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    is_spoiler: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    status: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "published",
    },
  },
  {
    sequelize: postgres,
    modelName: "reviews",
    tableName: "reviews",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { fields: ["user_id"] },
      { fields: ["content_id"] },
      { fields: ["rating"] },
      { fields: ["status"] },
      { unique: true, fields: ["user_id", "content_id"] },
    ],
  },
);

module.exports = Reviews;
