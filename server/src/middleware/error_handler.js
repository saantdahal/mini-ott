export const errorHandler = (err, req, res, next) => {
  console.error("Global error handler:", {
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    timestamp: new Date().toISOString(),
  });

  const isDevelopment = process.env.NODE_ENV !== "production";

  res.status(err.status || err.statusCode || 500).json({
    success: false,
    status: err.status || err.statusCode || 500,
    message: err.message || "Internal server error",
    ...(isDevelopment && { stack: err.stack }),
    timestamp: new Date().toISOString(),
  });
};

export const notFoundHandler = (req, res) => {
  res.status(404).json({
    success: false,
    status: 404,
    message: `Route ${req.originalUrl} not found`,
    timestamp: new Date().toISOString(),
  });
};