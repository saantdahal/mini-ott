const bcrypt = require("bcryptjs");

const truthy = new Set(["true", "1", "yes", "y"]);

const isTruthy = (value) => truthy.has(String(value || "").trim().toLowerCase());

const seedAdminUser = async () => {
  const Users = require("../model/users.model");

  const adminEmail = String(process.env.ADMIN_EMAIL || "admin@miniott.com")
    .trim()
    .toLowerCase();
  const adminPassword = String(process.env.ADMIN_PASSWORD || "Admin@12345").trim();
  const adminName = String(process.env.ADMIN_FULL_NAME || "Super Admin").trim();
  const resetPasswordOnBoot = isTruthy(process.env.SEED_ADMIN_RESET_PASSWORD);

  if (!adminEmail || !adminPassword) {
    console.warn("Admin seed skipped: ADMIN_EMAIL or ADMIN_PASSWORD is missing.");
    return;
  }

  const existingAdmin = await Users.findOne({ where: { email: adminEmail } });

  if (!existingAdmin) {
    const passwordHash = await bcrypt.hash(adminPassword, 10);
    await Users.create({
      full_name: adminName,
      email: adminEmail,
      password_hash: passwordHash,
      auth_provider: "email",
      role: "admin",
      is_email_verified: true,
      status: "active",
    });

    console.info(`Admin user seeded: ${adminEmail}`);
    return;
  }

  const updates = {
    role: existingAdmin.role === "admin" ? existingAdmin.role : "admin",
    auth_provider:
      existingAdmin.auth_provider === "email" ? existingAdmin.auth_provider : "email",
    is_email_verified: existingAdmin.is_email_verified ? true : true,
    status: existingAdmin.status === "active" ? "active" : "active",
  };

  if (!existingAdmin.full_name) {
    updates.full_name = adminName;
  }

  if (!existingAdmin.password_hash || resetPasswordOnBoot) {
    updates.password_hash = await bcrypt.hash(adminPassword, 10);
  }

  const hasChanges = Object.keys(updates).some(
    (key) => String(existingAdmin[key]) !== String(updates[key]),
  );

  if (hasChanges) {
    await existingAdmin.update(updates);
    console.info(`Admin user updated: ${adminEmail}`);
  } else {
    console.info(`ℹAdmin user already configured: ${adminEmail}`);
  }
};

module.exports = { seedAdminUser };