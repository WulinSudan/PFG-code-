import { Schema, model } from "mongoose";

interface IUser {
    name: string;
    password: string;
}

const schema = new Schema<IUser>({
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

export default model<IUser>("User", schema);
