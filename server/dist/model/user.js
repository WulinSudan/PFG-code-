"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.User = void 0;
const mongoose_1 = __importStar(require("mongoose"));
// User Schema
const UserSchema = new mongoose_1.Schema({
    dni: {
        type: String,
        unique: true,
        required: true,
        validate: {
            validator: function (v) {
                // Expresión regular para validar el formato de dni: 8 dígitos seguidos de 1 letra
                return /^\d{8}[A-Za-z]$/.test(v);
            },
            message: (props) => `${props.value} no es un DNI válido. Debe tener 8 dígitos seguidos de 1 letra.`,
        },
    },
    name: { type: String, required: true },
    password: { type: String, required: true },
    role: { type: String, default: "client", required: true },
    active: { type: Boolean, default: true, required: true },
    accounts: [{ type: mongoose_1.Schema.Types.ObjectId, ref: 'Account' }],
    logs: { type: [String], default: [] },
});
// User Model
const User = mongoose_1.default.model('User', UserSchema);
exports.User = User;
