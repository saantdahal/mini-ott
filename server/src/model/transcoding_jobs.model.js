const { Model, DataTypes } = require("sequelize");
const { postgres } = require("../config/db/database");

class TranscodingJobs extends Model {}

TranscodingJobs.init(
  {
    transcoding_job_id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },

    video_upload_id: {
      type: DataTypes.UUID,
      allowNull: false,
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

    // Source reference (S3 key or local file path)
    source_s3_key: {
      type: DataTypes.STRING(700),
      allowNull: true,
    },

    // Output HLS manifest S3 key
    output_manifest_key: {
      type: DataTypes.STRING(700),
      allowNull: true,
    },

    // Output path prefix for all HLS files
    output_path_prefix: {
      type: DataTypes.STRING(700),
      allowNull: true,
    },

    status: {
      type: DataTypes.STRING(50),
      allowNull: false,
      defaultValue: "pending",
      // pending, submitted, progressing, complete, error, cancelled
    },

    // Transcoding progress percentage (0-100)
    progress_percent: {
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: 0,
    },

    // Output resolutions generated
    output_resolutions: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: [],
      // e.g. [{ label: "480p", width: 854, height: 480 }, ...]
    },

    error_message: {
      type: DataTypes.TEXT,
      allowNull: true,
    },

    initiated_by: {
      type: DataTypes.UUID,
      allowNull: false,
    },

    completed_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    sequelize: postgres,
    tableName: "transcoding_jobs",
    timestamps: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
    indexes: [
      { fields: ["video_upload_id"] },
      { fields: ["content_id"] },
      { fields: ["episode_id"] },
      { fields: ["status"] },
      { fields: ["video_upload_id", "status"] },
    ],
  }
);

module.exports = TranscodingJobs;
