"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const authService_1 = require("../services/authService");
async function initializeRoles() {
    try {
        console.log('Initializing roles...');
        await authService_1.AuthService.initializeRoles();
        console.log('✓ Roles initialized successfully');
    }
    catch (error) {
        console.error('✗ Failed to initialize roles:', error);
    }
}
initializeRoles().then(() => {
    console.log('Role initialization completed');
    process.exit(0);
}).catch((error) => {
    console.error('Role initialization failed:', error);
    process.exit(1);
});
//# sourceMappingURL=initRoles.js.map