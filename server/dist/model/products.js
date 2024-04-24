import { Double, ObjectId } from 'mongodb';
import mongoose from 'mongoose'

const Schema = mongoose.Schema;

const productSchema = new Schema({
    name: String
});


export default mongoose.model('Product', productSchema, 'product');


