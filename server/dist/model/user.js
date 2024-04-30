import mongoose, { mongo } from "mongoose";

const schema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
        minlength: 3
    },
    password: {
        type: String,
        required: true,
        unique: true,
        minlength: 3
    }
})


export default mongoose.model('User',schema)