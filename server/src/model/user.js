import mongoose, { mongo } from "mongoose";
import person from "./person";

const schema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
        minlength: 3
    },
    friends: [
       {
        ref: person,
        type: mongoose.Schema.Types.ObjectId
       }
    ]
})


export default mongoose.model('User',schema)