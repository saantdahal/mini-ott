const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class Votes extends Model {}

Votes.init(
  {
    vote_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    voting_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    candidate_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    user_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    wallet_transaction_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    coins_used: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 1,
    },
    ip_address: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    user_agent: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
  },
  {
    sequelize: postgres,
    modelName: "votes",
    tableName: "votes",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: false,
    indexes: [
      { fields: ["voting_id"] },
      { fields: ["candidate_id"] },
      { fields: ["user_id"] },
      { fields: ["created_at"] },
    ],
  },
);

module.exports = Votes;
