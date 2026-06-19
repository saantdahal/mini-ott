const {
  createCategoryService,
  getAllCategoriesService,
  getCategoryByIdService,
  updateCategoryService,
  deleteCategoryService,
  createGenreService,
  getAllGenresService,
  getGenreByIdService,
  updateGenreService,
  deleteGenreService,
  createContentService,
  listContentsService,
  getContentByIdService,
  updateContentService,
  deleteContentService,
  createSeasonService,
  listSeasonsService,
  getSeasonByIdService,
  updateSeasonService,
  deleteSeasonService,
  createEpisodeService,
  listEpisodesService,
  getEpisodeByIdService,
  updateEpisodeService,
  deleteEpisodeService,
} = require("../services/content.service");

const {
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
} = require("../validator/content.validator");

const { getPublicCloudFrontUrl } = require("../services/cloudfront.service");

// Recursively add `<field>_url` for every `<field>_key` on every row, so the
// frontend can render images without knowing the CloudFront domain.
const URL_KEY_FIELDS = ["poster", "banner", "thumbnail"];
const RELATION_FIELDS = ["seasons", "episodes"];

const hydrateRow = (row) => {
  if (row == null) return row;
  const plain = typeof row.get === "function" ? row.get({ plain: true }) : row;
  const out = { ...plain };
  for (const field of URL_KEY_FIELDS) {
    const keyField = `${field}_key`;
    const urlField = `${field}_url`;
    if (keyField in out && !(urlField in out)) {
      out[urlField] = out[keyField] ? getPublicCloudFrontUrl(out[keyField]) : null;
    }
  }
  for (const relation of RELATION_FIELDS) {
    if (Array.isArray(out[relation])) {
      out[relation] = out[relation].map(hydrateRow);
    }
  }
  return out;
};

const hydrate = (result) => {
  if (result == null) return result;
  if (Array.isArray(result)) return result.map(hydrateRow);
  if (Array.isArray(result.items)) {
    return { ...result, items: result.items.map(hydrateRow) };
  }
  return hydrateRow(result);
};

const requireAdmin = (req) => {
  if (!req.user || req.user.role !== "admin") {
    const err = new Error("Admin privileges required");
    err.status = 403;
    throw err;
  }
};

const sendError = (res, error, fallbackStatus = 400) => {
  const status = error.status || fallbackStatus;
  return res.status(status).json({
    success: false,
    message: error.message,
  });
};

// ─── Category controllers ───────────────────────────────────────────

const createCategory = async (req, res) => {
  try {
    requireAdmin(req);
    const payload = validateCreateCategoryPayload(req.body);
    const result = await createCategoryService(payload);
    return res.status(201).json({
      success: true,
      message: "Category created successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error);
  }
};

const getAllCategories = async (req, res) => {
  try {
    const result = await getAllCategoriesService();
    return res.status(200).json({
      success: true,
      message: "Categories fetched successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

const getCategoryById = async (req, res) => {
  try {
    const result = await getCategoryByIdService(req.params.id);
    return res.status(200).json({
      success: true,
      message: "Category fetched successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

const updateCategory = async (req, res) => {
  try {
    requireAdmin(req);
    const payload = validateUpdateCategoryPayload(req.body);
    const result = await updateCategoryService(req.params.id, payload);
    return res.status(200).json({
      success: true,
      message: "Category updated successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error);
  }
};

const deleteCategory = async (req, res) => {
  try {
    requireAdmin(req);
    const result = await deleteCategoryService(req.params.id);
    return res.status(200).json({
      success: true,
      message: "Category deleted successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

// ─── Genre controllers ──────────────────────────────────────────────

const createGenre = async (req, res) => {
  try {
    requireAdmin(req);
    const payload = validateCreateGenrePayload(req.body);
    const result = await createGenreService(payload);
    return res.status(201).json({
      success: true,
      message: "Genre created successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error);
  }
};

const getAllGenres = async (req, res) => {
  try {
    const result = await getAllGenresService();
    return res.status(200).json({
      success: true,
      message: "Genres fetched successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

const getGenreById = async (req, res) => {
  try {
    const result = await getGenreByIdService(req.params.id);
    return res.status(200).json({
      success: true,
      message: "Genre fetched successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

const updateGenre = async (req, res) => {
  try {
    requireAdmin(req);
    const payload = validateUpdateGenrePayload(req.body);
    const result = await updateGenreService(req.params.id, payload);
    return res.status(200).json({
      success: true,
      message: "Genre updated successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error);
  }
};

const deleteGenre = async (req, res) => {
  try {
    requireAdmin(req);
    const result = await deleteGenreService(req.params.id);
    return res.status(200).json({
      success: true,
      message: "Genre deleted successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

// ─── Content controllers ────────────────────────────────────────────

const createContent = async (req, res) => {
  try {
    requireAdmin(req);
    const payload = validateCreateContentPayload(req.body);
    const result = await createContentService(payload, req.user.id);
    return res.status(201).json({
      success: true,
      message: "Content created successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error);
  }
};

const listContents = async (req, res) => {
  try {
    const query = validateListContentsQuery(req.query);
    const result = await listContentsService(query);
    return res.status(200).json({
      success: true,
      message: "Contents fetched successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error);
  }
};

const getContentById = async (req, res) => {
  try {
    const result = await getContentByIdService(req.params.id);
    return res.status(200).json({
      success: true,
      message: "Content fetched successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

const updateContent = async (req, res) => {
  try {
    requireAdmin(req);
    const payload = validateUpdateContentPayload(req.body);
    const result = await updateContentService(
      req.params.id,
      payload,
      req.user.id,
    );
    return res.status(200).json({
      success: true,
      message: "Content updated successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error);
  }
};

const deleteContent = async (req, res) => {
  try {
    requireAdmin(req);
    const result = await deleteContentService(req.params.id);
    return res.status(200).json({
      success: true,
      message: "Content deleted successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

// ─── Season controllers ─────────────────────────────────────────────

const createSeason = async (req, res) => {
  try {
    requireAdmin(req);
    const payload = validateCreateSeasonPayload(req.body);
    const result = await createSeasonService(req.params.contentId, payload);
    return res.status(201).json({
      success: true,
      message: "Season created successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error);
  }
};

const listSeasons = async (req, res) => {
  try {
    const result = await listSeasonsService(req.params.contentId);
    return res.status(200).json({
      success: true,
      message: "Seasons fetched successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

const getSeasonById = async (req, res) => {
  try {
    const result = await getSeasonByIdService(req.params.id);
    return res.status(200).json({
      success: true,
      message: "Season fetched successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

const updateSeason = async (req, res) => {
  try {
    requireAdmin(req);
    const payload = validateUpdateSeasonPayload(req.body);
    const result = await updateSeasonService(req.params.id, payload);
    return res.status(200).json({
      success: true,
      message: "Season updated successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error);
  }
};

const deleteSeason = async (req, res) => {
  try {
    requireAdmin(req);
    const result = await deleteSeasonService(req.params.id);
    return res.status(200).json({
      success: true,
      message: "Season deleted successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

// ─── Episode controllers ────────────────────────────────────────────

const createEpisode = async (req, res) => {
  try {
    requireAdmin(req);
    const payload = validateCreateEpisodePayload(req.body);
    const result = await createEpisodeService(req.params.contentId, payload);
    return res.status(201).json({
      success: true,
      message: "Episode created successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error);
  }
};

const listEpisodesByContent = async (req, res) => {
  try {
    const result = await listEpisodesService({
      contentId: req.params.contentId,
    });
    return res.status(200).json({
      success: true,
      message: "Episodes fetched successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

const listEpisodesBySeason = async (req, res) => {
  try {
    const result = await listEpisodesService({ seasonId: req.params.seasonId });
    return res.status(200).json({
      success: true,
      message: "Episodes fetched successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

const getEpisodeById = async (req, res) => {
  try {
    const result = await getEpisodeByIdService(req.params.id);
    return res.status(200).json({
      success: true,
      message: "Episode fetched successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

const updateEpisode = async (req, res) => {
  try {
    requireAdmin(req);
    const payload = validateUpdateEpisodePayload(req.body);
    const result = await updateEpisodeService(req.params.id, payload);
    return res.status(200).json({
      success: true,
      message: "Episode updated successfully",
      result: hydrate(result),
    });
  } catch (error) {
    return sendError(res, error);
  }
};

const deleteEpisode = async (req, res) => {
  try {
    requireAdmin(req);
    const result = await deleteEpisodeService(req.params.id);
    return res.status(200).json({
      success: true,
      message: "Episode deleted successfully",
      result,
    });
  } catch (error) {
    return sendError(res, error, 500);
  }
};

module.exports = {
  createCategory,
  getAllCategories,
  getCategoryById,
  updateCategory,
  deleteCategory,
  createGenre,
  getAllGenres,
  getGenreById,
  updateGenre,
  deleteGenre,
  createContent,
  listContents,
  getContentById,
  updateContent,
  deleteContent,
  createSeason,
  listSeasons,
  getSeasonById,
  updateSeason,
  deleteSeason,
  createEpisode,
  listEpisodesByContent,
  listEpisodesBySeason,
  getEpisodeById,
  updateEpisode,
  deleteEpisode,
};
