import nodemailer from "nodemailer";

const buildTransport = () => {
  const { SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, SMTP_FROM } = process.env;

  if (!SMTP_USER || !SMTP_PASSWORD) {
    throw new Error("SMTP_USER or SMTP_PASSWORD is not set. Check your environment variables.");
  }
  if (!SMTP_HOST) {
    throw new Error("SMTP_HOST is not set. Check your environment variables.");
  }

  return nodemailer.createTransport({
    host: SMTP_HOST,
    port: parseInt(SMTP_PORT || "587"),
    secure: parseInt(SMTP_PORT || "587") === 465,
    auth: {
      user: SMTP_USER,
      pass: SMTP_PASSWORD,
    },
  });
};

export const sendEMail = async (mailInfo) => {
  try {
    const transport = buildTransport();
    const info = await transport.sendMail(mailInfo);
    console.log("Message sent: %s", info.messageId);
  } catch (error) {
    console.log("Error in sending mail: ", error.message);
  }
};