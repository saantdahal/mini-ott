let associationsApplied = false;

const Users = require("./users.model");
const Contents = require("./contents.model");
const Categories = require("./categories.model");
const ContentCategories = require("./content_categories.model");
const Genres = require("./genres.model");
const ContentGenres = require("./content_genres.model");
const Seasons = require("./seasons.model");
const Episodes = require("./episodes.model");

const Votings = require("./votings.model");
const VotingCandidates = require("./voting_candidates.model");
const Votes = require("./votes.model");

const Wallets = require("./wallets.model");
const CoinPackages = require("./coin_packages.model");
const Payments = require("./payments.model");
const WalletTransactions = require("./wallet_transactions.model");

const UserContentAccess = require("./user_content_access.model");
const WatchHistory = require("./watch_history.model");
const Watchlists = require("./watchlists.model");

const Banners = require("./banners.model");
const Notifications = require("./notifications.model");
const DeviceSessions = require("./device_sessions.model");
const Reviews = require("./reviews.model");
const EmailVerificationOtps = require("./email_verification_otps.model");
const VideoUploads = require("./video_uploads.model");
const TranscodingJobs = require("./transcoding_jobs.model");

const applyAssociations = () => {
  if (associationsApplied) return;
  associationsApplied = true;

  // Users <-> Contents (audit)
  Users.hasMany(Contents, { foreignKey: "created_by", as: "created_contents" });
  Contents.belongsTo(Users, { foreignKey: "created_by", as: "creator" });

  // Users <-> Email verification OTPs
  Users.hasMany(EmailVerificationOtps, {
    foreignKey: "user_id",
    as: "email_verification_otps",
  });
  EmailVerificationOtps.belongsTo(Users, {
    foreignKey: "user_id",
    as: "user",
  });

  Users.hasMany(Contents, { foreignKey: "updated_by", as: "updated_contents" });
  Contents.belongsTo(Users, { foreignKey: "updated_by", as: "updater" });

  // Contents hierarchy
  Contents.hasMany(Seasons, { foreignKey: "content_id", as: "seasons" });
  Seasons.belongsTo(Contents, { foreignKey: "content_id", as: "content" });

  Contents.hasMany(Episodes, { foreignKey: "content_id", as: "episodes" });
  Episodes.belongsTo(Contents, { foreignKey: "content_id", as: "content" });

  Seasons.hasMany(Episodes, { foreignKey: "season_id", as: "episodes" });
  Episodes.belongsTo(Seasons, { foreignKey: "season_id", as: "season" });

  // Contents <-> Categories (many-to-many)
  Contents.belongsToMany(Categories, {
    through: ContentCategories,
    foreignKey: "content_id",
    otherKey: "category_id",
    as: "categories",
  });
  Categories.belongsToMany(Contents, {
    through: ContentCategories,
    foreignKey: "category_id",
    otherKey: "content_id",
    as: "contents",
  });

  ContentCategories.belongsTo(Contents, {
    foreignKey: "content_id",
    as: "content",
  });
  ContentCategories.belongsTo(Categories, {
    foreignKey: "category_id",
    as: "category",
  });
  Contents.hasMany(ContentCategories, {
    foreignKey: "content_id",
    as: "content_category_links",
  });
  Categories.hasMany(ContentCategories, {
    foreignKey: "category_id",
    as: "content_category_links",
  });

  // Contents <-> Genres (many-to-many)
  Contents.belongsToMany(Genres, {
    through: ContentGenres,
    foreignKey: "content_id",
    otherKey: "genre_id",
    as: "genres",
  });
  Genres.belongsToMany(Contents, {
    through: ContentGenres,
    foreignKey: "genre_id",
    otherKey: "content_id",
    as: "contents",
  });

  ContentGenres.belongsTo(Contents, {
    foreignKey: "content_id",
    as: "content",
  });
  ContentGenres.belongsTo(Genres, { foreignKey: "genre_id", as: "genre" });
  Contents.hasMany(ContentGenres, {
    foreignKey: "content_id",
    as: "content_genre_links",
  });
  Genres.hasMany(ContentGenres, {
    foreignKey: "genre_id",
    as: "content_genre_links",
  });

  // Voting
  Users.hasMany(Votings, { foreignKey: "created_by", as: "created_votings" });
  Votings.belongsTo(Users, { foreignKey: "created_by", as: "creator" });

  Votings.hasMany(VotingCandidates, {
    foreignKey: "voting_id",
    as: "candidates",
  });
  VotingCandidates.belongsTo(Votings, {
    foreignKey: "voting_id",
    as: "voting",
  });

  Contents.hasMany(VotingCandidates, {
    foreignKey: "content_id",
    as: "voting_candidates",
  });
  VotingCandidates.belongsTo(Contents, {
    foreignKey: "content_id",
    as: "content",
  });

  Votings.hasMany(Votes, { foreignKey: "voting_id", as: "votes" });
  Votes.belongsTo(Votings, { foreignKey: "voting_id", as: "voting" });

  VotingCandidates.hasMany(Votes, { foreignKey: "candidate_id", as: "votes" });
  Votes.belongsTo(VotingCandidates, {
    foreignKey: "candidate_id",
    as: "candidate",
  });

  Users.hasMany(Votes, { foreignKey: "user_id", as: "votes" });
  Votes.belongsTo(Users, { foreignKey: "user_id", as: "user" });

  // Wallets & payments
  Users.hasOne(Wallets, { foreignKey: "user_id", as: "wallet" });
  Wallets.belongsTo(Users, { foreignKey: "user_id", as: "user" });

  Users.hasMany(Payments, { foreignKey: "user_id", as: "payments" });
  Payments.belongsTo(Users, { foreignKey: "user_id", as: "user" });

  CoinPackages.hasMany(Payments, {
    foreignKey: "coin_package_id",
    as: "payments",
  });
  Payments.belongsTo(CoinPackages, {
    foreignKey: "coin_package_id",
    as: "coin_package",
  });

  Wallets.hasMany(WalletTransactions, {
    foreignKey: "wallet_id",
    as: "transactions",
  });
  WalletTransactions.belongsTo(Wallets, {
    foreignKey: "wallet_id",
    as: "wallet",
  });

  Users.hasMany(WalletTransactions, {
    foreignKey: "user_id",
    as: "wallet_transactions",
  });
  WalletTransactions.belongsTo(Users, { foreignKey: "user_id", as: "user" });

  Payments.hasMany(WalletTransactions, {
    foreignKey: "payment_id",
    as: "wallet_transactions",
  });
  WalletTransactions.belongsTo(Payments, {
    foreignKey: "payment_id",
    as: "payment",
  });

  Users.hasMany(WalletTransactions, {
    foreignKey: "created_by",
    as: "created_wallet_transactions",
  });
  WalletTransactions.belongsTo(Users, {
    foreignKey: "created_by",
    as: "created_by_user",
  });

  Votes.belongsTo(WalletTransactions, {
    foreignKey: "wallet_transaction_id",
    as: "wallet_transaction",
  });
  WalletTransactions.hasMany(Votes, {
    foreignKey: "wallet_transaction_id",
    as: "votes",
  });

  // Content access
  Users.hasMany(UserContentAccess, {
    foreignKey: "user_id",
    as: "content_access",
  });
  UserContentAccess.belongsTo(Users, { foreignKey: "user_id", as: "user" });

  Contents.hasMany(UserContentAccess, {
    foreignKey: "content_id",
    as: "content_access",
  });
  UserContentAccess.belongsTo(Contents, {
    foreignKey: "content_id",
    as: "content",
  });

  Episodes.hasMany(UserContentAccess, {
    foreignKey: "episode_id",
    as: "content_access",
  });
  UserContentAccess.belongsTo(Episodes, {
    foreignKey: "episode_id",
    as: "episode",
  });

  UserContentAccess.belongsTo(Payments, {
    foreignKey: "source_payment_id",
    as: "source_payment",
  });
  Payments.hasMany(UserContentAccess, {
    foreignKey: "source_payment_id",
    as: "content_access_grants",
  });

  UserContentAccess.belongsTo(WalletTransactions, {
    foreignKey: "source_wallet_transaction_id",
    as: "source_wallet_transaction",
  });
  WalletTransactions.hasMany(UserContentAccess, {
    foreignKey: "source_wallet_transaction_id",
    as: "content_access_grants",
  });

  // Watch history
  Users.hasMany(WatchHistory, { foreignKey: "user_id", as: "watch_history" });
  WatchHistory.belongsTo(Users, { foreignKey: "user_id", as: "user" });

  Contents.hasMany(WatchHistory, {
    foreignKey: "content_id",
    as: "watch_history",
  });
  WatchHistory.belongsTo(Contents, { foreignKey: "content_id", as: "content" });

  Episodes.hasMany(WatchHistory, {
    foreignKey: "episode_id",
    as: "watch_history",
  });
  WatchHistory.belongsTo(Episodes, { foreignKey: "episode_id", as: "episode" });

  // Watchlists
  Users.hasMany(Watchlists, { foreignKey: "user_id", as: "watchlist_entries" });
  Watchlists.belongsTo(Users, { foreignKey: "user_id", as: "user" });

  Contents.hasMany(Watchlists, {
    foreignKey: "content_id",
    as: "watchlist_entries",
  });
  Watchlists.belongsTo(Contents, { foreignKey: "content_id", as: "content" });

  Users.belongsToMany(Contents, {
    through: Watchlists,
    foreignKey: "user_id",
    otherKey: "content_id",
    as: "watchlisted_contents",
  });
  Contents.belongsToMany(Users, {
    through: Watchlists,
    foreignKey: "content_id",
    otherKey: "user_id",
    as: "watchlisted_by_users",
  });

  // Banners
  Contents.hasMany(Banners, { foreignKey: "linked_content_id", as: "banners" });
  Banners.belongsTo(Contents, {
    foreignKey: "linked_content_id",
    as: "linked_content",
  });

  Votings.hasMany(Banners, { foreignKey: "linked_voting_id", as: "banners" });
  Banners.belongsTo(Votings, {
    foreignKey: "linked_voting_id",
    as: "linked_voting",
  });

  // Notifications
  Users.hasMany(Notifications, { foreignKey: "user_id", as: "notifications" });
  Notifications.belongsTo(Users, { foreignKey: "user_id", as: "user" });

  // Device sessions
  Users.hasMany(DeviceSessions, {
    foreignKey: "user_id",
    as: "device_sessions",
  });
  DeviceSessions.belongsTo(Users, { foreignKey: "user_id", as: "user" });

  // Reviews
  Users.hasMany(Reviews, { foreignKey: "user_id", as: "reviews" });
  Reviews.belongsTo(Users, { foreignKey: "user_id", as: "user" });

  Contents.hasMany(Reviews, { foreignKey: "content_id", as: "reviews" });
  Reviews.belongsTo(Contents, { foreignKey: "content_id", as: "content" });

  // Video uploads
  Users.hasMany(VideoUploads, {
    foreignKey: "initiated_by",
    as: "video_uploads",
  });
  VideoUploads.belongsTo(Users, {
    foreignKey: "initiated_by",
    as: "initiator",
  });

  Contents.hasMany(VideoUploads, {
    foreignKey: "content_id",
    as: "video_uploads",
  });
  VideoUploads.belongsTo(Contents, {
    foreignKey: "content_id",
    as: "content",
  });

  Seasons.hasMany(VideoUploads, {
    foreignKey: "season_id",
    as: "video_uploads",
  });
  VideoUploads.belongsTo(Seasons, {
    foreignKey: "season_id",
    as: "season",
  });

  Episodes.hasMany(VideoUploads, {
    foreignKey: "episode_id",
    as: "video_uploads",
  });
  VideoUploads.belongsTo(Episodes, {
    foreignKey: "episode_id",
    as: "episode",
  });

  // Transcoding jobs
  VideoUploads.hasMany(TranscodingJobs, {
    foreignKey: "video_upload_id",
    as: "transcoding_jobs",
  });
  TranscodingJobs.belongsTo(VideoUploads, {
    foreignKey: "video_upload_id",
    as: "video_upload",
  });

  Users.hasMany(TranscodingJobs, {
    foreignKey: "initiated_by",
    as: "transcoding_jobs",
  });
  TranscodingJobs.belongsTo(Users, {
    foreignKey: "initiated_by",
    as: "initiator",
  });

  Contents.hasMany(TranscodingJobs, {
    foreignKey: "content_id",
    as: "transcoding_jobs",
  });
  TranscodingJobs.belongsTo(Contents, {
    foreignKey: "content_id",
    as: "content",
  });

  Episodes.hasMany(TranscodingJobs, {
    foreignKey: "episode_id",
    as: "transcoding_jobs",
  });
  TranscodingJobs.belongsTo(Episodes, {
    foreignKey: "episode_id",
    as: "episode",
  });
};

module.exports = {
  applyAssociations,
  models: {
    Users,
    Contents,
    Categories,
    ContentCategories,
    Genres,
    ContentGenres,
    Seasons,
    Episodes,
    Votings,
    VotingCandidates,
    Votes,
    Wallets,
    CoinPackages,
    Payments,
    WalletTransactions,
    UserContentAccess,
    WatchHistory,
    Watchlists,
    Banners,
    Notifications,
    DeviceSessions,
    Reviews,
    VideoUploads,
    TranscodingJobs,
  },
};
