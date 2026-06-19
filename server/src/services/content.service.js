const { Op } = require("sequelize");

const { postgres } = require("../config/db/database");
const Categories = require("../model/categories.model");
const Genres = require("../model/genres.model");
const Contents = require("../model/contents.model");
const Seasons = require("../model/seasons.model");
const Episodes = require("../model/episodes.model");
const VideoUploads = require("../model/video_uploads.model");
const ContentCategories = require("../model/content_categories.model");
const ContentGenres = require("../model/content_genres.model");

// ─── Slug helper ────────────────────────────────────────────────────
const generateSlug = (name) =>
  String(name)
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");

const httpError = (message, status) => {
  const error = new Error(message);
  error.status = status;
  return error;
};

// ─── Category services ──────────────────────────────────────────────

async function createCategoryService(data) {
  const slug = data.slug || generateSlug(data.name);

  const existingName = await Categories.findOne({
    where: { name: data.name },
  });
  if (existingName) {
    throw httpError("Category with this name already exists", 409);
  }

  const existingSlug = await Categories.findOne({ where: { slug } });
  if (existingSlug) {
    throw httpError("Category with this slug already exists", 409);
  }

  const category = await Categories.create({
    ...data,
    slug,
  });

  return category;
}

async function getAllCategoriesService() {
  const categories = await Categories.findAll({
    order: [["sort_order", "ASC"]],
  });
  return categories;
}

async function getCategoryByIdService(categoryId) {
  const category = await Categories.findByPk(categoryId);
  if (!category) {
    throw httpError("Category not found", 404);
  }
  return category;
}

async function updateCategoryService(categoryId, data) {
  const category = await Categories.findByPk(categoryId);
  if (!category) {
    throw httpError("Category not found", 404);
  }

  if (data.name && data.name !== category.name) {
    const existingName = await Categories.findOne({
      where: { name: data.name },
    });
    if (existingName) {
      throw httpError("Category with this name already exists", 409);
    }
  }

  const slug = data.slug || (data.name ? generateSlug(data.name) : undefined);

  if (slug && slug !== category.slug) {
    const existingSlug = await Categories.findOne({ where: { slug } });
    if (existingSlug) {
      throw httpError("Category with this slug already exists", 409);
    }
  }

  const updatePayload = { ...data };
  if (slug) {
    updatePayload.slug = slug;
  }

  await category.update(updatePayload);
  return category;
}

async function deleteCategoryService(categoryId) {
  const category = await Categories.findByPk(categoryId);
  if (!category) {
    throw httpError("Category not found", 404);
  }

  await category.destroy();
  return { category_id: categoryId };
}

// ─── Genre services ─────────────────────────────────────────────────

async function createGenreService(data) {
  const slug = data.slug || generateSlug(data.name);

  const existingName = await Genres.findOne({
    where: { name: data.name },
  });
  if (existingName) {
    throw httpError("Genre with this name already exists", 409);
  }

  const existingSlug = await Genres.findOne({ where: { slug } });
  if (existingSlug) {
    throw httpError("Genre with this slug already exists", 409);
  }

  const genre = await Genres.create({
    ...data,
    slug,
  });

  return genre;
}

async function getAllGenresService() {
  const genres = await Genres.findAll({
    order: [["name", "ASC"]],
  });
  return genres;
}

async function getGenreByIdService(genreId) {
  const genre = await Genres.findByPk(genreId);
  if (!genre) {
    throw httpError("Genre not found", 404);
  }
  return genre;
}

async function updateGenreService(genreId, data) {
  const genre = await Genres.findByPk(genreId);
  if (!genre) {
    throw httpError("Genre not found", 404);
  }

  if (data.name && data.name !== genre.name) {
    const existingName = await Genres.findOne({
      where: { name: data.name },
    });
    if (existingName) {
      throw httpError("Genre with this name already exists", 409);
    }
  }

  const slug = data.slug || (data.name ? generateSlug(data.name) : undefined);

  if (slug && slug !== genre.slug) {
    const existingSlug = await Genres.findOne({ where: { slug } });
    if (existingSlug) {
      throw httpError("Genre with this slug already exists", 409);
    }
  }

  const updatePayload = { ...data };
  if (slug) {
    updatePayload.slug = slug;
  }

  await genre.update(updatePayload);
  return genre;
}

async function deleteGenreService(genreId) {
  const genre = await Genres.findByPk(genreId);
  if (!genre) {
    throw httpError("Genre not found", 404);
  }

  await genre.destroy();
  return { genre_id: genreId };
}

// ─── Content helpers ────────────────────────────────────────────────

const includeContentRelations = [
  {
    model: Categories,
    as: "categories",
    through: { attributes: [] },
  },
  {
    model: Genres,
    as: "genres",
    through: { attributes: [] },
  },
];

async function assertCategoriesExist(categoryIds) {
  if (!categoryIds || categoryIds.length === 0) return;
  const found = await Categories.findAll({
    where: { category_id: { [Op.in]: categoryIds } },
    attributes: ["category_id"],
  });
  if (found.length !== categoryIds.length) {
    throw httpError("One or more category_ids are invalid", 400);
  }
}

async function assertGenresExist(genreIds) {
  if (!genreIds || genreIds.length === 0) return;
  const found = await Genres.findAll({
    where: { genre_id: { [Op.in]: genreIds } },
    attributes: ["genre_id"],
  });
  if (found.length !== genreIds.length) {
    throw httpError("One or more genre_ids are invalid", 400);
  }
}

async function buildPlaybackUploadIndex(contentId) {
  const uploads = await VideoUploads.findAll({
    where: { content_id: contentId },
    attributes: ["video_upload_id", "episode_id", "created_at"],
    order: [["created_at", "DESC"]],
  });

  const episodeUploadIds = new Map();
  let contentUploadId = null;

  for (const upload of uploads) {
    const record = upload.get({ plain: true });

    if (!contentUploadId && !record.episode_id) {
      contentUploadId = record.video_upload_id;
    }

    if (record.episode_id && !episodeUploadIds.has(record.episode_id)) {
      episodeUploadIds.set(record.episode_id, record.video_upload_id);
    }
  }

  return { contentUploadId, episodeUploadIds };
}

function attachPlaybackUploadIds(content, playbackIndex) {
  const plain = content.get({ plain: true });

  plain.video_upload_id = playbackIndex.contentUploadId;

  if (Array.isArray(plain.episodes)) {
    plain.episodes = plain.episodes.map((episode) => ({
      ...episode,
      video_upload_id:
        playbackIndex.episodeUploadIds.get(episode.episode_id) || null,
    }));
  }

  if (Array.isArray(plain.seasons)) {
    plain.seasons = plain.seasons.map((season) => ({
      ...season,
      episodes: Array.isArray(season.episodes)
        ? season.episodes.map((episode) => ({
            ...episode,
            video_upload_id:
              playbackIndex.episodeUploadIds.get(episode.episode_id) || null,
          }))
        : season.episodes,
    }));
  }

  return plain;
}

// ─── Content services ───────────────────────────────────────────────

async function createContentService(data, userId) {
  const { category_ids: categoryIds, genre_ids: genreIds, ...rest } = data;
  const slug = rest.slug || generateSlug(rest.title);

  const existingSlug = await Contents.findOne({ where: { slug } });
  if (existingSlug) {
    throw httpError("Content with this slug already exists", 409);
  }

  await assertCategoriesExist(categoryIds);
  await assertGenresExist(genreIds);

  const publishedAt =
    rest.published_at || (rest.status === "published" ? new Date() : null);

  return postgres.transaction(async (transaction) => {
    const content = await Contents.create(
      {
        ...rest,
        slug,
        published_at: publishedAt,
        created_by: userId,
        updated_by: userId,
      },
      { transaction },
    );

    if (categoryIds && categoryIds.length > 0) {
      await content.setCategories(categoryIds, { transaction });
    }
    if (genreIds && genreIds.length > 0) {
      await content.setGenres(genreIds, { transaction });
    }

    return Contents.findByPk(content.content_id, {
      include: includeContentRelations,
      transaction,
    });
  });
}

async function listContentsService(query) {
  const {
    page,
    limit,
    search,
    content_type: contentType,
    status,
    access_type: accessType,
    category_id: categoryId,
    genre_id: genreId,
  } = query;

  const where = {};
  if (contentType) where.content_type = contentType;
  if (status) where.status = status;
  if (accessType) where.access_type = accessType;
  if (search) where.title = { [Op.iLike]: `%${search}%` };

  const include = [
    {
      model: Categories,
      as: "categories",
      through: { attributes: [] },
      ...(categoryId
        ? { where: { category_id: categoryId }, required: true }
        : {}),
    },
    {
      model: Genres,
      as: "genres",
      through: { attributes: [] },
      ...(genreId ? { where: { genre_id: genreId }, required: true } : {}),
    },
  ];

  const offset = (page - 1) * limit;

  const { rows, count } = await Contents.findAndCountAll({
    where,
    include,
    order: [["created_at", "DESC"]],
    limit,
    offset,
    distinct: true,
    subQuery: false,
  });

  return {
    items: rows,
    pagination: {
      page,
      limit,
      total: count,
      total_pages: Math.ceil(count / limit) || 0,
    },
  };
}

async function getContentByIdService(contentId) {
  const content = await Contents.findByPk(contentId, {
    include: [
      ...includeContentRelations,
      {
        model: Seasons,
        as: "seasons",
        separate: true,
        order: [["season_number", "ASC"]],
      },
      {
        model: Episodes,
        as: "episodes",
        separate: true,
        order: [
          ["season_id", "ASC"],
          ["episode_number", "ASC"],
        ],
      },
    ],
  });
  if (!content) {
    throw httpError("Content not found", 404);
  }

  const playbackIndex = await buildPlaybackUploadIndex(contentId);
  return attachPlaybackUploadIds(content, playbackIndex);
}

async function updateContentService(contentId, data, userId) {
  const content = await Contents.findByPk(contentId);
  if (!content) {
    throw httpError("Content not found", 404);
  }

  const { category_ids: categoryIds, genre_ids: genreIds, ...rest } = data;

  let slug;
  if (rest.slug) {
    slug = rest.slug;
  } else if (rest.title && rest.title !== content.title) {
    slug = generateSlug(rest.title);
  }

  if (slug && slug !== content.slug) {
    const existingSlug = await Contents.findOne({
      where: { slug, content_id: { [Op.ne]: contentId } },
    });
    if (existingSlug) {
      throw httpError("Content with this slug already exists", 409);
    }
  }

  await assertCategoriesExist(categoryIds);
  await assertGenresExist(genreIds);

  const updatePayload = { ...rest, updated_by: userId };
  if (slug) updatePayload.slug = slug;

  if (
    rest.status === "published" &&
    content.status !== "published" &&
    !rest.published_at &&
    !content.published_at
  ) {
    updatePayload.published_at = new Date();
  }

  return postgres.transaction(async (transaction) => {
    await content.update(updatePayload, { transaction });

    if (Array.isArray(categoryIds)) {
      await content.setCategories(categoryIds, { transaction });
    }
    if (Array.isArray(genreIds)) {
      await content.setGenres(genreIds, { transaction });
    }

    return Contents.findByPk(contentId, {
      include: includeContentRelations,
      transaction,
    });
  });
}

async function deleteContentService(contentId) {
  const content = await Contents.findByPk(contentId);
  if (!content) {
    throw httpError("Content not found", 404);
  }

  await postgres.transaction(async (transaction) => {
    await Episodes.destroy({ where: { content_id: contentId }, transaction });
    await Seasons.destroy({ where: { content_id: contentId }, transaction });
    await ContentCategories.destroy({
      where: { content_id: contentId },
      transaction,
    });
    await ContentGenres.destroy({
      where: { content_id: contentId },
      transaction,
    });
    await content.destroy({ transaction });
  });

  return { content_id: contentId };
}

// ─── Season services ────────────────────────────────────────────────

async function createSeasonService(contentId, data) {
  const content = await Contents.findByPk(contentId);
  if (!content) {
    throw httpError("Content not found", 404);
  }

  const existing = await Seasons.findOne({
    where: { content_id: contentId, season_number: data.season_number },
  });
  if (existing) {
    throw httpError(
      "Season with this season_number already exists for this content",
      409,
    );
  }

  return postgres.transaction(async (transaction) => {
    const season = await Seasons.create(
      { ...data, content_id: contentId },
      { transaction },
    );

    const totalSeasons = await Seasons.count({
      where: { content_id: contentId },
      transaction,
    });
    await content.update(
      { total_seasons: totalSeasons, is_series: true },
      { transaction },
    );

    return season;
  });
}

async function listSeasonsService(contentId) {
  const content = await Contents.findByPk(contentId);
  if (!content) {
    throw httpError("Content not found", 404);
  }

  return Seasons.findAll({
    where: { content_id: contentId },
    order: [["season_number", "ASC"]],
  });
}

async function getSeasonByIdService(seasonId) {
  const season = await Seasons.findByPk(seasonId, {
    include: [
      {
        model: Episodes,
        as: "episodes",
        separate: true,
        order: [["episode_number", "ASC"]],
      },
    ],
  });
  if (!season) {
    throw httpError("Season not found", 404);
  }

  const playbackIndex = await buildPlaybackUploadIndex(season.content_id);
  const plain = season.get({ plain: true });
  plain.episodes = Array.isArray(plain.episodes)
    ? plain.episodes.map((episode) => ({
        ...episode,
        video_upload_id:
          playbackIndex.episodeUploadIds.get(episode.episode_id) || null,
      }))
    : plain.episodes;

  return plain;
}

async function updateSeasonService(seasonId, data) {
  const season = await Seasons.findByPk(seasonId);
  if (!season) {
    throw httpError("Season not found", 404);
  }

  if (data.season_number && data.season_number !== season.season_number) {
    const existing = await Seasons.findOne({
      where: {
        content_id: season.content_id,
        season_number: data.season_number,
        season_id: { [Op.ne]: seasonId },
      },
    });
    if (existing) {
      throw httpError(
        "Season with this season_number already exists for this content",
        409,
      );
    }
  }

  await season.update(data);
  return season;
}

async function deleteSeasonService(seasonId) {
  const season = await Seasons.findByPk(seasonId);
  if (!season) {
    throw httpError("Season not found", 404);
  }

  const contentId = season.content_id;

  await postgres.transaction(async (transaction) => {
    await Episodes.destroy({ where: { season_id: seasonId }, transaction });
    await season.destroy({ transaction });

    const [totalSeasons, totalEpisodes] = await Promise.all([
      Seasons.count({ where: { content_id: contentId }, transaction }),
      Episodes.count({ where: { content_id: contentId }, transaction }),
    ]);
    await Contents.update(
      { total_seasons: totalSeasons, total_episodes: totalEpisodes },
      { where: { content_id: contentId }, transaction },
    );
  });

  return { season_id: seasonId };
}

// ─── Episode services ───────────────────────────────────────────────

async function createEpisodeService(contentId, data) {
  const content = await Contents.findByPk(contentId);
  if (!content) {
    throw httpError("Content not found", 404);
  }

  if (data.season_id) {
    const season = await Seasons.findByPk(data.season_id);
    if (!season || season.content_id !== contentId) {
      throw httpError("Season not found for this content", 400);
    }
  }

  const slug = data.slug || generateSlug(data.title);

  const duplicateNumber = await Episodes.findOne({
    where: {
      content_id: contentId,
      season_id: data.season_id || null,
      episode_number: data.episode_number,
    },
  });
  if (duplicateNumber) {
    throw httpError(
      "Episode with this episode_number already exists in this season",
      409,
    );
  }

  return postgres.transaction(async (transaction) => {
    const episode = await Episodes.create(
      { ...data, slug, content_id: contentId },
      { transaction },
    );

    const totalEpisodes = await Episodes.count({
      where: { content_id: contentId },
      transaction,
    });
    await content.update({ total_episodes: totalEpisodes }, { transaction });

    return episode;
  });
}

async function listEpisodesService({ contentId, seasonId }) {
  const where = {};
  let playbackContentId = contentId || null;
  if (contentId) {
    const content = await Contents.findByPk(contentId);
    if (!content) {
      throw httpError("Content not found", 404);
    }
    where.content_id = contentId;
  }
  if (seasonId) {
    const season = await Seasons.findByPk(seasonId);
    if (!season) {
      throw httpError("Season not found", 404);
    }
    where.season_id = seasonId;
    playbackContentId = playbackContentId || season.content_id;
  }

  const episodes = await Episodes.findAll({
    where,
    order: [
      ["season_id", "ASC"],
      ["episode_number", "ASC"],
    ],
  });

  const playbackIndex = await buildPlaybackUploadIndex(
    playbackContentId || episodes[0]?.content_id,
  );
  return episodes.map((episode) => {
    const plain = episode.get({ plain: true });
    plain.video_upload_id =
      playbackIndex.episodeUploadIds.get(plain.episode_id) || null;
    return plain;
  });
}

async function getEpisodeByIdService(episodeId) {
  const episode = await Episodes.findByPk(episodeId);
  if (!episode) {
    throw httpError("Episode not found", 404);
  }

  const playbackIndex = await buildPlaybackUploadIndex(episode.content_id);
  const plain = episode.get({ plain: true });
  plain.video_upload_id =
    playbackIndex.episodeUploadIds.get(plain.episode_id) || null;
  return plain;
}

async function updateEpisodeService(episodeId, data) {
  const episode = await Episodes.findByPk(episodeId);
  if (!episode) {
    throw httpError("Episode not found", 404);
  }

  const nextSeasonId =
    data.season_id === undefined ? episode.season_id : data.season_id;

  if (
    data.season_id !== undefined &&
    data.season_id !== null &&
    data.season_id !== episode.season_id
  ) {
    const season = await Seasons.findByPk(data.season_id);
    if (!season || season.content_id !== episode.content_id) {
      throw httpError("Season not found for this content", 400);
    }
  }

  const nextEpisodeNumber = data.episode_number ?? episode.episode_number;
  if (
    nextSeasonId !== episode.season_id ||
    nextEpisodeNumber !== episode.episode_number
  ) {
    const existing = await Episodes.findOne({
      where: {
        content_id: episode.content_id,
        season_id: nextSeasonId,
        episode_number: nextEpisodeNumber,
        episode_id: { [Op.ne]: episodeId },
      },
    });
    if (existing) {
      throw httpError(
        "Episode with this episode_number already exists in this season",
        409,
      );
    }
  }

  let slug = data.slug;
  if (!slug && data.title && data.title !== episode.title) {
    slug = generateSlug(data.title);
  }

  const updatePayload = { ...data };
  if (slug) updatePayload.slug = slug;

  await episode.update(updatePayload);
  return episode;
}

async function deleteEpisodeService(episodeId) {
  const episode = await Episodes.findByPk(episodeId);
  if (!episode) {
    throw httpError("Episode not found", 404);
  }

  const contentId = episode.content_id;

  await postgres.transaction(async (transaction) => {
    await episode.destroy({ transaction });
    const totalEpisodes = await Episodes.count({
      where: { content_id: contentId },
      transaction,
    });
    await Contents.update(
      { total_episodes: totalEpisodes },
      { where: { content_id: contentId }, transaction },
    );
  });

  return { episode_id: episodeId };
}

module.exports = {
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
};
