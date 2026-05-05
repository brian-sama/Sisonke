"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const db_1 = require("../db");
const schema_1 = require("../db/schema");
const auth_1 = require("../middleware/auth");
const errorHandler_1 = require("../middleware/errorHandler");
const router = (0, express_1.Router)();
const PushTokenSchema = zod_1.z.object({
    token: zod_1.z.string().min(20),
    platform: zod_1.z.string().min(2).max(40),
});
router.use(auth_1.authMiddleware);
router.post('/push-token', (0, errorHandler_1.asyncHandler)(async (req, res) => {
    const input = PushTokenSchema.parse(req.body);
    await db_1.db.insert(schema_1.notifications).values({
        userId: req.user.id,
        channel: 'push-token',
        title: 'Push token registered',
        body: 'Device can receive counselor and safety updates.',
        metadata: {
            token: input.token,
            platform: input.platform,
            updatedAt: new Date().toISOString(),
        },
    });
    res.status(204).send();
}));
exports.default = router;
//# sourceMappingURL=notifications.js.map