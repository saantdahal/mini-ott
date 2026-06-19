const cron = require("node-cron");

async function deleteUnverifiedUsers(params) {
  try {
    cron.schedule("0 0 * * *", async () => {
      const oneDayAgo = new Date(Date.now() - 1 * 24 * 60 * 60 * 1000);
      await Users.destroy({
        where: {
          is_verified: false,
          created_at: {
            [Op.lt]: oneDayAgo,
          },
        },
      });
    });
  } catch (error) {
    console.error("Error deleting unverified users:", error);
  }
}

module.exports = {
  deleteUnverifiedUsers,
};
