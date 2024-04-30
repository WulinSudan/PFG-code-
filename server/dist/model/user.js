import mongoose from 'mongoose';

const schema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    phone: {
        type: String
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

export default mongoose.model('User',schema)