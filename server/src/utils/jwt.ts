import { verify, sign } from "jsonwebtoken";
import { Context } from "./context";
import { Types } from "mongoose";

const secret = "paraula-secreta";

interface Token {
    user: string;
}

export function getAccessToken(payload: any, options: any) {
    return sign(payload, secret, {
        ...(options && options),
        algorithm: "HS256",
    });
}

export function getUserId(context: Context) {
    const authHeader = context.req.get("Authorization");
    if (authHeader) {
        const token = authHeader.replace("Bearer ", "");
        const verifiedToken = verify(token, secret) as Token;
        return verifiedToken && verifiedToken.user;
    }
}
