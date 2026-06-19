const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class VotingCandidates extends Model {}

VotingCandidates.init(
  {
    candidate_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    voting_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    content_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    candidate_name: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    candidate_type: {
      type: DataTypes.STRING(50),
      allowNull: false,
      defaultValue: "content",
    },
    photo_key: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    bio: {
      type: DataTypes.TEXT,
      allowNull: true,
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
    modelName: "voting_candidates",
    tableName: "voting_candidates",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { fields: ["voting_id"] },
      { fields: ["content_id"] },
      { fields: ["status"] },
    ],
  },
);

module.exports = VotingCandidates;
