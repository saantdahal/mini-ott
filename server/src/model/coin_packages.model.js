const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class CoinPackages extends Model {}

CoinPackages.init(
  {
    coin_package_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    title: {
      type: DataTypes.STRING(150),
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    coins: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    bonus_coins: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    price_amount: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: false,
    },
    currency: {
      type: DataTypes.STRING(10),
      allowNull: false,
      defaultValue: "NPR",
    },
    is_popular: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    sort_order: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    status: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "active",
    },
  },
  {
    sequelize: postgres,
    modelName: "coin_packages",
    tableName: "coin_packages",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [{ fields: ["status"] }, { fields: ["sort_order"] }],
  },
);

module.exports = CoinPackages;
