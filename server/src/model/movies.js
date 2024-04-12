const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const movieSchema = new Schema({
    imdbID: String,
    Title: String,
});

module.exports = mongoose.model('Movie', movieSchema);