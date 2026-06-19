const Joi = require("joi");

const initUploadSchema = Joi.object({
  content_id: Joi.string().trim().uuid().required(),
  season_id: Joi.string().trim().uuid().empty("").default(null).allow(null),
  episode_id: Joi.string().trim().uuid().empty("").default(null).allow(null),
  upload_for: Joi.string()
    .trim()
    .lowercase()
    .valid("episode_video", "movie_trailer", "season_trailer")
    .required(),
  file_name: Joi.string().trim().max(255).required(),
  mime_type: Joi.string().trim().max(150).required(),
  file_size: Joi.number().integer().min(1).required(),
});

const signPartSchema = Joi.object({
  video_upload_id: Joi.string().trim().uuid().required(),
  part_number: Joi.number().integer().min(1).max(10000).required(),
});

const completeUploadSchema = Joi.object({
  video_upload_id: Joi.string().trim().uuid().required(),
  parts: Joi.array()
    .items(
      Joi.object({
        PartNumber: Joi.number().integer().min(1).max(10000).required(),
        ETag: Joi.string().trim().required(),
      }),
    )
    .min(1)
    .required(),
});

const savePartSchema = Joi.object({
  video_upload_id: Joi.string().trim().uuid().required(),
  part_number: Joi.number().integer().min(1).max(10000).required(),
  etag: Joi.string().trim().required(),
});

const abortUploadSchema = Joi.object({
  video_upload_id: Joi.string().trim().uuid().required(),
});

const validateWithSchema = (schema, body) => {
  const { error, value } = schema.validate(body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    throw new Error(error.details.map((item) => item.message).join(", "));
  }

  return value;
};

const validateInitUploadPayload = (body) =>
  validateWithSchema(initUploadSchema, body);

const validateSignPartPayload = (body) =>
  validateWithSchema(signPartSchema, body);

const validateCompleteUploadPayload = (body) =>
  validateWithSchema(completeUploadSchema, body);

const validateSavePartPayload = (body) =>
  validateWithSchema(savePartSchema, body);

const validateAbortUploadPayload = (body) =>
  validateWithSchema(abortUploadSchema, body);

module.exports = {
  validateInitUploadPayload,
  validateSignPartPayload,
  validateSavePartPayload,
  validateCompleteUploadPayload,
  validateAbortUploadPayload,
};
