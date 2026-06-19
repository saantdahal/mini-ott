const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class ContentCategories extends Model {}

ContentCategories.init(
  {
    content_category_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    content_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    category_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
  },
  {
    sequelize: postgres,
    modelName: "content_categories",
    tableName: "content_categories",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: false,
    indexes: [
      { unique: true, fields: ["content_id", "category_id"] },
      { fields: ["category_id"] },
    ],
  },
);

module.exports = ContentCategories;
