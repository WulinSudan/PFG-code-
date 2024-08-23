import { Schema, model, Document } from 'mongoose';

// Interface for Dictionary
interface IDictionary extends Document {
  encrypt_message: string;
  account: string;
  create_date: Date;
  enable: boolean;
}

// Dictionary Schema
const dictionarySchema = new Schema<IDictionary>({
  encrypt_message: {
    type: String,
    required: true,
    unique: true,
  },
  account: {
    type: String,
    required: true,
  },
  create_date: {
    type: Date,
    required: true,
    default: Date.now, // Set default to current date if not provided
  },
  enable: {
    type: Boolean,
    required: true,
    default: true,
  },
});

// Dictionary Model
const Dictionary = model<IDictionary>('Dictionary', dictionarySchema);

export default Dictionary;
