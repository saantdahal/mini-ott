const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class Wallets extends Model {}

Wallets.init(
  {
    wallet_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
      unique: true,
    },
    balance_coins: {
      type: DataTypes.BIGINT,
      allowNull: false,
      defaultValue: 0,
    },
    total_earned_coins: {
      type: DataTypes.BIGINT,
      allowNull: false,
      defaultValue: 0,
    },
    total_spent_coins: {
      type: DataTypes.BIGINT,
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
    modelName: "wallets",
    tableName: "wallets",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [{ unique: true, fields: ["user_id"] }, { fields: ["status"] }],
  },
);

module.exports = Wallets;
