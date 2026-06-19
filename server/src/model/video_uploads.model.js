const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class VideoUploads extends Model {}

VideoUploads.init(
  {
    video_upload_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },

    content_id: {
      type: DataTypes.UUID,
      allowNull: false,
    },

    season_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },

    episode_id: {
      type: DataTypes.UUID,
      allowNull: true,
    },

    upload_for: {
      type: DataTypes.STRING(50), // movie, episode, trailer, teaser, subtitle
      allowNull: false,
    },

    bucket_name: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },

    s3_key: {
      type: DataTypes.STRING(700),
      allowNull: false,
    },

    upload_id: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },

    status: {
      type: DataTypes.STRING(30), // initiated, uploading, uploaded, failed, cancelled
      allowNull: false,
      defaultValue: "initiated",
    },

    file_name: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },

    mime_type: {
      type: DataTypes.STRING(150),
      allowNull: true,
    },

    file_size: {
      type: DataTypes.BIGINT,
      allowNull: true,
    },

    etag: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },

    checksum: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },

    parts_uploaded: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: [],
    },

    initiated_by: {
      type: DataTypes.UUID,
      allowNull: false,
    },

    error_message: {
      type: DataTypes.TEXT,
      allowNull: true,
    },

    uploaded_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    sequelize: postgres,
    modelName: "video_uploads",
    tableName: "video_uploads",
    timestamps: true,
    underscored: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { fields: ["content_id"] },
      { fields: ["season_id"] },
      { fields: ["episode_id"] },
      { fields: ["upload_for"] },
      { fields: ["status"] },
      { fields: ["initiated_by"] },
      { fields: ["upload_id"] },
      { fields: ["bucket_name"] },
      { fields: ["content_id", "status"] },
      { fields: ["episode_id", "status"] },
    ],
  },
);

module.exports = VideoUploads;
