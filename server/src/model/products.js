import { Double, ObjectId } from 'mongodb';
import mongoose from 'mongoose'

const Schema = mongoose.Schema;

const productSchema = new Schema({
    _id: ObjectId,
    prodId: Number,
    price: Double,
    quantity: Number
});


export default mongoose.model('Product', productSchema, 'product');


