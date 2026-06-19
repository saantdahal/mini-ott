const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class Banners extends Model {}

Banners.init(
  {
    banner_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    subtitle: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    image_key: {
      type: DataTypes.STRING(500),
      allowNull: false,
    },
    mobile_image_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    linked_content_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    linked_voting_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    cta_text: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    cta_url: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    sort_order: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    start_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    end_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    status: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "active",
    },
  },
  {
    sequelize: postgres,
    modelName: "banners",
    tableName: "banners",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { fields: ["linked_content_id"] },
      { fields: ["linked_voting_id"] },
      { fields: ["status"] },
      { fields: ["sort_order"] },
    ],
  },
);

module.exports = Banners;
