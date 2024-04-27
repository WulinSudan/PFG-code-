import mongoose from "mongoose";
import Person from "./person.js";

const schema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
        minlength: 3
    },
    friends: [
       {
        ref: Person,
        type: mongoose.Schema.Types.ObjectId
       }
    ]
})


export default mongoose.model('User',schema)