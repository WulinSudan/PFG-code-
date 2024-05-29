import { Schema, model } from "mongoose";

interface IAccount {
    owner: string;
    number_account: string;
    balance: number;
    active: boolean;
}

const schema = new Schema<IAccount>({
    owner: {
        type: String,
        required: true,
        unique: true,
    },
    number_account: {
        type: String,
        required: true,
        unique: true,
        minlength: 10,
    },
    balance: {
        type: Number,
        required: true,
        unique: false,
    },
    active: {
        type: Boolean,
        required: true,
    },
});

schema.index({ number_account: 1 });

export default model<IAccount>("Account", schema);
