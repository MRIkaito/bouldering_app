"use strict";
/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
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
// import {onRequest} from "firebase-functions/v2/https";
// import * as logger from "firebase-functions/logger";
const functions = __importStar(require("firebase-functions"));
const pg_1 = require("pg");
// Start writing functions
// https://firebase.google.com/docs/functions/typescript
// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const dbConfig = {
    user: "postgres",
    host: "35.185.152.107",
    database: "test_boulder_app_db",
    password: "d8@q]kI|HJD&6G|I",
    port: 5432,
};
const pool = new pg_1.Pool(dbConfig);
// サンプル関数：データベースからデータを取得
exports.getData = functions.https.onRequest(async (req, res) => {
    try {
        const client = await pool.connect();
        const result = await client.query("SELECT * FROM climbingtypes");
        client.release();
        res.status(200).json(result.rows);
    }
    catch (error) {
        console.error("Error querying database:", error);
        res.status(500).send("Error querying database");
    }
});
//# sourceMappingURL=index.js.map