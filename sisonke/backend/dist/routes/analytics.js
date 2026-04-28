"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const errorHandler_1 = require("../middleware/errorHandler");
const types_1 = require("../types");
const router = (0, express_1.Router)();
router.post('/events', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = types_1.AnalyticsEventSchema.parse(req.body);
    await db_1.db.insert(schema_1.analyticsEvents).values({
        event: input.event,
        resourceId: input.resourceId,
        category: input.category,
        platform: input.platform,
        appVersion: input.appVersion,
        locale: input.locale,
        metadata: input.metadata,
    });
    res.status(202).json({ success: true });
}));
exports.default = router;
//# sourceMappingURL=analytics.js.map