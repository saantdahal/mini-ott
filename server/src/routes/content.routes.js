const express = require("express");

const auth = require("../middleware/auth");
const {
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
} = require("../controller/content.controller");

const router = express.Router();

// ─── Categories ─────────────────────────────────────────────────────
router.post("/categories", auth, createCategory);
router.get("/categories", getAllCategories);
router.get("/categories/:id", getCategoryById);
router.put("/categories/:id", auth, updateCategory);
router.delete("/categories/:id", auth, deleteCategory);

// ─── Genres ─────────────────────────────────────────────────────────
router.post("/genres", auth, createGenre);
router.get("/genres", getAllGenres);
router.get("/genres/:id", getGenreById);
router.put("/genres/:id", auth, updateGenre);
router.delete("/genres/:id", auth, deleteGenre);

// ─── Contents ───────────────────────────────────────────────────────
router.post("/contents", auth, createContent);
router.get("/contents", listContents);
router.get("/contents/:id", getContentById);
router.put("/contents/:id", auth, updateContent);
router.delete("/contents/:id", auth, deleteContent);

// ─── Seasons (nested under content for create/list) ────────────────
router.post("/contents/:contentId/seasons", auth, createSeason);
router.get("/contents/:contentId/seasons", listSeasons);
router.get("/seasons/:id", getSeasonById);
router.put("/seasons/:id", auth, updateSeason);
router.delete("/seasons/:id", auth, deleteSeason);

// ─── Episodes (nested under content/season for create/list) ────────
router.post("/contents/:contentId/episodes", auth, createEpisode);
router.get("/contents/:contentId/episodes", listEpisodesByContent);
router.get("/seasons/:seasonId/episodes", listEpisodesBySeason);
router.get("/episodes/:id", getEpisodeById);
router.put("/episodes/:id", auth, updateEpisode);
router.delete("/episodes/:id", auth, deleteEpisode);

module.exports = router;
