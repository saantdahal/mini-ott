const Joi = require("joi");

// ─── Shared helpers ─────────────────────────────────────────────────
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

const slugPattern = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const uuidSchema = Joi.string().uuid({ version: "uuidv4" });

// ─── Category schemas ───────────────────────────────────────────────
const createCategorySchema = Joi.object({
  name: Joi.string().trim().min(1).max(100).required(),
  slug: Joi.string()
    .trim()
    .lowercase()
    .max(120)
    .pattern(slugPattern)
    .optional(),
  description: Joi.string()
    .trim()
    .max(2000)
    .empty("")
    .default(null)
    .allow(null),
  sort_order: Joi.number().integer().min(0).optional(),
  status: Joi.string()
    .trim()
    .lowercase()
    .valid("active", "inactive")
    .default("active"),
});

const updateCategorySchema = Joi.object({
  name: Joi.string().trim().min(1).max(100).optional(),
  slug: Joi.string()
    .trim()
    .lowercase()
    .max(120)
    .pattern(slugPattern)
    .optional(),
  description: Joi.string()
    .trim()
    .max(2000)
    .empty("")
    .default(null)
    .allow(null),
  sort_order: Joi.number().integer().min(0).optional(),
  status: Joi.string()
    .trim()
    .lowercase()
    .valid("active", "inactive")
    .optional(),
}).min(1);

// ─── Genre schemas ──────────────────────────────────────────────────
const createGenreSchema = Joi.object({
  name: Joi.string().trim().min(1).max(100).required(),
  slug: Joi.string()
    .trim()
    .lowercase()
    .max(120)
    .pattern(slugPattern)
    .optional(),
  description: Joi.string()
    .trim()
    .max(2000)
    .empty("")
    .default(null)
    .allow(null),
  status: Joi.string()
    .trim()
    .lowercase()
    .valid("active", "inactive")
    .default("active"),
});

const updateGenreSchema = Joi.object({
  name: Joi.string().trim().min(1).max(100).optional(),
  slug: Joi.string()
    .trim()
    .lowercase()
    .max(120)
    .pattern(slugPattern)
    .optional(),
  description: Joi.string()
    .trim()
    .max(2000)
    .empty("")
    .default(null)
    .allow(null),
  status: Joi.string()
    .trim()
    .lowercase()
    .valid("active", "inactive")
    .optional(),
}).min(1);

// ─── Content schemas ────────────────────────────────────────────────
const contentStatusValues = ["draft", "published", "archived"];
const accessTypeValues = ["free", "premium"];
const contentTypeValues = ["movie", "series", "documentary", "short"];

const createContentSchema = Joi.object({
  title: Joi.string().trim().min(1).max(255).required(),
  slug: Joi.string()
    .trim()
    .lowercase()
    .max(255)
    .pattern(slugPattern)
    .optional(),
  description: Joi.string().trim().empty("").default(null).allow(null),
  short_description: Joi.string()
    .trim()
    .max(500)
    .empty("")
    .default(null)
    .allow(null),
  content_type: Joi.string()
    .trim()
    .lowercase()
    .valid(...contentTypeValues)
    .required(),
  is_series: Joi.boolean().default(false),
  language: Joi.string().trim().max(50).empty("").default(null).allow(null),
  country: Joi.string().trim().max(100).empty("").default(null).allow(null),
  age_rating: Joi.string().trim().max(20).empty("").default(null).allow(null),
  release_date: Joi.date().iso().empty("").default(null).allow(null),
  duration_seconds: Joi.number()
    .integer()
    .min(0)
    .empty("")
    .default(null)
    .allow(null),
  thumbnail_key: Joi.string()
    .trim()
    .max(500)
    .empty("")
    .default(null)
    .allow(null),
  poster_key: Joi.string().trim().max(500).empty("").default(null).allow(null),
  banner_key: Joi.string().trim().max(500).empty("").default(null).allow(null),
  trailer_key: Joi.string().trim().max(500).empty("").default(null).allow(null),
  stream_manifest_key: Joi.string()
    .trim()
    .max(500)
    .empty("")
    .default(null)
    .allow(null),
  access_type: Joi.string()
    .trim()
    .lowercase()
    .valid(...accessTypeValues)
    .default("free"),
  required_coins: Joi.number().integer().min(0).default(0),
  seo_title: Joi.string().trim().max(255).empty("").default(null).allow(null),
  seo_description: Joi.string()
    .trim()
    .max(500)
    .empty("")
    .default(null)
    .allow(null),
  status: Joi.string()
    .trim()
    .lowercase()
    .valid(...contentStatusValues)
    .default("draft"),
  published_at: Joi.date().iso().empty("").default(null).allow(null),
  category_ids: Joi.array().items(uuidSchema).default([]),
  genre_ids: Joi.array().items(uuidSchema).default([]),
});

const updateContentSchema = Joi.object({
  title: Joi.string().trim().min(1).max(255).optional(),
  slug: Joi.string()
    .trim()
    .lowercase()
    .max(255)
    .pattern(slugPattern)
    .optional(),
  description: Joi.string().trim().empty("").allow(null),
  short_description: Joi.string().trim().max(500).empty("").allow(null),
  content_type: Joi.string()
    .trim()
    .lowercase()
    .valid(...contentTypeValues)
    .optional(),
  is_series: Joi.boolean().optional(),
  language: Joi.string().trim().max(50).empty("").allow(null),
  country: Joi.string().trim().max(100).empty("").allow(null),
  age_rating: Joi.string().trim().max(20).empty("").allow(null),
  release_date: Joi.date().iso().empty("").allow(null),
  duration_seconds: Joi.number().integer().min(0).empty("").allow(null),
  thumbnail_key: Joi.string().trim().max(500).empty("").allow(null),
  poster_key: Joi.string().trim().max(500).empty("").allow(null),
  banner_key: Joi.string().trim().max(500).empty("").allow(null),
  trailer_key: Joi.string().trim().max(500).empty("").allow(null),
  stream_manifest_key: Joi.string().trim().max(500).empty("").allow(null),
  access_type: Joi.string()
    .trim()
    .lowercase()
    .valid(...accessTypeValues)
    .optional(),
  required_coins: Joi.number().integer().min(0).optional(),
  seo_title: Joi.string().trim().max(255).empty("").allow(null),
  seo_description: Joi.string().trim().max(500).empty("").allow(null),
  status: Joi.string()
    .trim()
    .lowercase()
    .valid(...contentStatusValues)
    .optional(),
  published_at: Joi.date().iso().empty("").allow(null),
  category_ids: Joi.array().items(uuidSchema).optional(),
  genre_ids: Joi.array().items(uuidSchema).optional(),
}).min(1);

const listContentsQuerySchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  search: Joi.string().trim().max(255).empty("").optional(),
  content_type: Joi.string()
    .trim()
    .lowercase()
    .valid(...contentTypeValues)
    .optional(),
  status: Joi.string()
    .trim()
    .lowercase()
    .valid(...contentStatusValues)
    .optional(),
  access_type: Joi.string()
    .trim()
    .lowercase()
    .valid(...accessTypeValues)
    .optional(),
  category_id: uuidSchema.optional(),
  genre_id: uuidSchema.optional(),
});

// ─── Season schemas ─────────────────────────────────────────────────
const seasonStatusValues = ["draft", "published", "archived"];

const createSeasonSchema = Joi.object({
  season_number: Joi.number().integer().min(1).required(),
  title: Joi.string().trim().max(255).empty("").default(null).allow(null),
  description: Joi.string().trim().empty("").default(null).allow(null),
  thumbnail_key: Joi.string()
    .trim()
    .max(500)
    .empty("")
    .default(null)
    .allow(null),
  trailer_key: Joi.string().trim().max(500).empty("").default(null).allow(null),
  release_date: Joi.date().iso().empty("").default(null).allow(null),
  status: Joi.string()
    .trim()
    .lowercase()
    .valid(...seasonStatusValues)
    .default("draft"),
});

const updateSeasonSchema = Joi.object({
  season_number: Joi.number().integer().min(1).optional(),
  title: Joi.string().trim().max(255).empty("").allow(null),
  description: Joi.string().trim().empty("").allow(null),
  thumbnail_key: Joi.string().trim().max(500).empty("").allow(null),
  trailer_key: Joi.string().trim().max(500).empty("").allow(null),
  release_date: Joi.date().iso().empty("").allow(null),
  status: Joi.string()
    .trim()
    .lowercase()
    .valid(...seasonStatusValues)
    .optional(),
}).min(1);

// ─── Episode schemas ────────────────────────────────────────────────
const episodeStatusValues = ["draft", "published", "archived"];

const createEpisodeSchema = Joi.object({
  season_id: uuidSchema.optional().allow(null),
  episode_number: Joi.number().integer().min(1).required(),
  title: Joi.string().trim().min(1).max(255).required(),
  slug: Joi.string()
    .trim()
    .lowercase()
    .max(255)
    .pattern(slugPattern)
    .empty("")
    .default(null)
    .allow(null),
  description: Joi.string().trim().empty("").default(null).allow(null),
  short_description: Joi.string()
    .trim()
    .max(500)
    .empty("")
    .default(null)
    .allow(null),
  thumbnail_key: Joi.string()
    .trim()
    .max(500)
    .empty("")
    .default(null)
    .allow(null),
  banner_key: Joi.string().trim().max(500).empty("").default(null).allow(null),
  video_key: Joi.string().trim().max(500).empty("").default(null).allow(null),
  stream_manifest_key: Joi.string()
    .trim()
    .max(500)
    .empty("")
    .default(null)
    .allow(null),
  subtitle_key: Joi.string()
    .trim()
    .max(500)
    .empty("")
    .default(null)
    .allow(null),
  duration_seconds: Joi.number()
    .integer()
    .min(0)
    .empty("")
    .default(null)
    .allow(null),
  release_date: Joi.date().iso().empty("").default(null).allow(null),
  access_type: Joi.string()
    .trim()
    .lowercase()
    .valid(...accessTypeValues)
    .default("free"),
  required_coins: Joi.number().integer().min(0).default(0),
  status: Joi.string()
    .trim()
    .lowercase()
    .valid(...episodeStatusValues)
    .default("draft"),
});

const updateEpisodeSchema = Joi.object({
  season_id: uuidSchema.optional().allow(null),
  episode_number: Joi.number().integer().min(1).optional(),
  title: Joi.string().trim().min(1).max(255).optional(),
  slug: Joi.string()
    .trim()
    .lowercase()
    .max(255)
    .pattern(slugPattern)
    .empty("")
    .allow(null),
  description: Joi.string().trim().empty("").allow(null),
  short_description: Joi.string().trim().max(500).empty("").allow(null),
  thumbnail_key: Joi.string().trim().max(500).empty("").allow(null),
  banner_key: Joi.string().trim().max(500).empty("").allow(null),
  video_key: Joi.string().trim().max(500).empty("").allow(null),
  stream_manifest_key: Joi.string().trim().max(500).empty("").allow(null),
  subtitle_key: Joi.string().trim().max(500).empty("").allow(null),
  duration_seconds: Joi.number().integer().min(0).empty("").allow(null),
  release_date: Joi.date().iso().empty("").allow(null),
  access_type: Joi.string()
    .trim()
    .lowercase()
    .valid(...accessTypeValues)
    .optional(),
  required_coins: Joi.number().integer().min(0).optional(),
  status: Joi.string()
    .trim()
    .lowercase()
    .valid(...episodeStatusValues)
    .optional(),
}).min(1);

// ─── Exports ────────────────────────────────────────────────────────
const validateCreateCategoryPayload = (body) =>
  validateWithSchema(createCategorySchema, body);

const validateUpdateCategoryPayload = (body) =>
  validateWithSchema(updateCategorySchema, body);

const validateCreateGenrePayload = (body) =>
  validateWithSchema(createGenreSchema, body);

const validateUpdateGenrePayload = (body) =>
  validateWithSchema(updateGenreSchema, body);

const validateCreateContentPayload = (body) =>
  validateWithSchema(createContentSchema, body);

const validateUpdateContentPayload = (body) =>
  validateWithSchema(updateContentSchema, body);

const validateListContentsQuery = (query) =>
  validateWithSchema(listContentsQuerySchema, query);

const validateCreateSeasonPayload = (body) =>
  validateWithSchema(createSeasonSchema, body);

const validateUpdateSeasonPayload = (body) =>
  validateWithSchema(updateSeasonSchema, body);

const validateCreateEpisodePayload = (body) =>
  validateWithSchema(createEpisodeSchema, body);

const validateUpdateEpisodePayload = (body) =>
  validateWithSchema(updateEpisodeSchema, body);

module.exports = {
  validateCreateCategoryPayload,
  validateUpdateCategoryPayload,
  validateCreateGenrePayload,
  validateUpdateGenrePayload,
  validateCreateContentPayload,
  validateUpdateContentPayload,
  validateListContentsQuery,
  validateCreateSeasonPayload,
  validateUpdateSeasonPayload,
  validateCreateEpisodePayload,
  validateUpdateEpisodePayload,
};
