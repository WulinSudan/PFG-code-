import { Schema, model } from "mongoose";

interface IPerson {
    name: string;
    phone: number;
    street: string;
    city: string;
}

const schema = new Schema<IPerson>({
    name: {
        type: String,
        required: true,
    },
    phone: {
        type: Number,
        required: true,
    },
    street: {
        type: String,
        required: true,
    },
    city: {
        type: String,
        required: true,
    },
});

export default model<IPerson>("Person", schema);
