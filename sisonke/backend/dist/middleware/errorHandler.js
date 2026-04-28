"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.asyncHandler = exports.notFound = exports.errorHandler = void 0;
const errorHandler = (err, req, res, next) => {
    let error = { ...err };
    error.message = err.message;
    // Log error
    console.error(err);
    // Drizzle validation error
    if (err.name === 'DrizzleError') {
        const message = 'Database validation error';
        error = { ...error, statusCode: 400, message };
    }
    // JWT error
    if (err.name === 'JsonWebTokenError') {
        const message = 'Invalid token';
        error = { ...error, statusCode: 401, message };
    }
    // JWT expired error
    if (err.name === 'TokenExpiredError') {
        const message = 'Token expired';
        error = { ...error, statusCode: 401, message };
    }
    // Zod validation error
    if (err.name === 'ZodError') {
        const message = 'Invalid input data';
        error = { ...error, statusCode: 400, message };
    }
    res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Server Error',
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    });
};
exports.errorHandler = errorHandler;
const notFound = (req, res, next) => {
    const error = new Error(`Not found - ${req.originalUrl}`);
    res.status(404);
    next(error);
};
exports.notFound = notFound;
const asyncHandler = (fn) => (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
};
exports.asyncHandler = asyncHandler;
//# sourceMappingURL=errorHandler.js.map