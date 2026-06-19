const CoinPackages = require("../model/coin_packages.model");
const { postgres } = require("../config/db/database");

function createAppError(message, { statusCode = 500, code, details } = {}) {
  const error = new Error(message);
  error.statusCode = statusCode;
  if (code) error.code = code;
  if (details) error.details = details;
  return error;
}

async function createCoinPackagesService(data) {
  try {
    if (!data || typeof data !== "object") {
      throw createAppError("Invalid coin package data", {
        statusCode: 400,
        code: "INVALID_COIN_PACKAGE_DATA",
      });
    }

    const sortOrderProvided =
      Object.prototype.hasOwnProperty.call(data, "sort_order") &&
      data.sort_order !== null &&
      data.sort_order !== "";

    const result = await postgres.transaction(async (transaction) => {
      await postgres.query("SELECT pg_advisory_xact_lock(:lockKey)", {
        transaction,
        replacements: { lockKey: 72499101 },
      });

      let payload = data;

      if (sortOrderProvided) {
        const providedSortOrder = Number(data.sort_order);
        if (!Number.isInteger(providedSortOrder) || providedSortOrder < 0) {
          throw createAppError(
            "Invalid sort_order; must be a non-negative integer",
            {
              statusCode: 400,
              code: "INVALID_SORT_ORDER",
              details: { field: "sort_order", value: data.sort_order },
            },
          );
        }

        const existing = await CoinPackages.findOne({
          attributes: ["coin_package_id"],
          where: { sort_order: providedSortOrder },
          transaction,
          lock: transaction.LOCK.UPDATE,
        });

        if (existing) {
          throw createAppError(
            `Sort order ${providedSortOrder} is already in use. Choose a different sort_order or leave it blank to auto-assign.`,
            {
              statusCode: 409,
              code: "COIN_PACKAGE_SORT_ORDER_TAKEN",
              details: {
                field: "sort_order",
                value: providedSortOrder,
                existingCoinPackageId: existing.coin_package_id,
              },
            },
          );
        }

        payload = { ...data, sort_order: providedSortOrder };
      } else {
        const lastPackage = await CoinPackages.findOne({
          attributes: ["sort_order"],
          order: [["sort_order", "DESC"]],
          transaction,
          lock: transaction.LOCK.UPDATE,
        });

        const nextSortOrder = (lastPackage?.sort_order ?? 0) + 1;
        payload = { ...data, sort_order: nextSortOrder };
      }

      return CoinPackages.create(payload, { transaction });
    });

    return result;
  } catch (error) {
    if (error?.statusCode || error?.code) {
      throw error;
    }

    throw createAppError(`Error creating coin package: ${error.message}`, {
      statusCode: 500,
      code: "COIN_PACKAGE_CREATE_FAILED",
    });
  }
}

async function getAllCoinPackagesService() {
  try {
    const coinPackages = await CoinPackages.findAll({
      order: [["sort_order", "ASC"]],
    });
    return coinPackages;
  } catch (error) {
    throw new Error(`Error fetching coin packages: ${error.message}`);
  }
}

module.exports = {
  createCoinPackagesService,
  getAllCoinPackagesService,
};
