import mongoose from 'mongoose'
const Schema = mongoose.Schema;

const movieSchema = new Schema({
    Id: String,
    Title: String,
});


export default mongoose.model('Movie', movieSchema);