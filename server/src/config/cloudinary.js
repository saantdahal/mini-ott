const cloudinary = require("cloudinary").v2;

const initCloudinary = () => {
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
  });

  if (!process.env.CLOUDINARY_CLOUD_NAME) {
    console.warn(" Cloudinary config incomplete. Image uploads will fail.");
  }
};

const uploadImageToCloudinary = async (fileBuffer, fileName) => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        folder: "miniott/avatars",
        public_id: fileName,
        resource_type: "auto",
      },
      (error, result) => {
        if (error) reject(error);
        else resolve(result);
      }
    );

    stream.end(fileBuffer);
  });
};

module.exports = {
  initCloudinary,
  uploadImageToCloudinary,
  cloudinary,
};
