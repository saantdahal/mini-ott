const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class Payments extends Model {}

Payments.init(
  {
    payment_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    coin_package_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    gateway: {
      type: DataTypes.STRING(30),
      allowNull: false,
    },
    gateway_transaction_id: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    gateway_reference: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    amount: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: false,
    },
    currency: {
      type: DataTypes.STRING(10),
      allowNull: false,
      defaultValue: "NPR",
    },
    coins_credited: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    payment_for: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "coin_purchase",
    },
    status: {
      type: DataTypes.STRING(30),
      allowNull: false,
      defaultValue: "pending",
    },
    paid_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    failure_reason: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    metadata: {
      type: DataTypes.JSONB,
      allowNull: true,
    },
  },
  {
    sequelize: postgres,
    modelName: "payments",
    tableName: "payments",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { fields: ["user_id"] },
      { fields: ["coin_package_id"] },
      { fields: ["gateway"] },
      { fields: ["gateway_transaction_id"] },
      { fields: ["status"] },
      { fields: ["paid_at"] },
    ],
  },
);

module.exports = Payments;
