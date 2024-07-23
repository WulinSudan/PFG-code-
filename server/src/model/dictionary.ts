import { Schema, model } from "mongoose";

const dictionarySchema = new Schema({
  encrypt_message: {
    type: String,
    required: true,
    unique: true,
  },
  account: {
    type: String,
    required: true,
  },
  operation: {
    type: String,
    required: true,
  },
  create_date: {
    type: Date,
    required: false,
  }

});

const Dictionary = model("Dictionary", dictionarySchema);
export default Dictionary;
