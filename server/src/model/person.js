import mongoose, { mongo } from 'mongoose';

const schema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    phone: {
        type: Number,
        required: true
    },
    street: {
        type: String,
        required: true
    },
    city: {
        type: String,
        required: true
    }
})

export default mongoose.model('Person',schema)