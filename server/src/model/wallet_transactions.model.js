const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class WalletTransactions extends Model {}

WalletTransactions.init(
  {
    wallet_transaction_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    wallet_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    payment_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    transaction_type: {
      type: DataTypes.STRING(30),
      allowNull: false,
    },
    source_type: {
      type: DataTypes.STRING(50),
      allowNull: false,
    },
    source_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    coins: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    balance_before: {
      type: DataTypes.BIGINT,
      allowNull: false,
    },
    balance_after: {
      type: DataTypes.BIGINT,
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    created_by: {
      type: DataTypes.UUID,
      allowNull: true,
    },
  },
  {
    sequelize: postgres,
    modelName: "wallet_transactions",
    tableName: "wallet_transactions",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: false,
    indexes: [
      { fields: ["wallet_id"] },
      { fields: ["user_id"] },
      { fields: ["payment_id"] },
      { fields: ["transaction_type"] },
      { fields: ["source_type"] },
      { fields: ["created_at"] },
    ],
  },
);

module.exports = WalletTransactions;
