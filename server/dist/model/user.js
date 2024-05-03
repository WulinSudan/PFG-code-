"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = require("mongoose");
const schema = new mongoose_1.Schema({
    name: {
        type: String,
        required: true,
        unique: true,
        minlength: 3,
    },
    password: {
        type: String,
        required: true,
        unique: true,
        minlength: 3,
    },
});
schema.index({ email: 1 });
exports.default = (0, mongoose_1.model)("User", schema);
