import mongoose, { Document, Schema, Model } from 'mongoose';
import { IAccount } from './account';

// Interface for User
interface IUser extends Document {
  dni: string;
  name: string;
  password: string;
  accounts: IAccount['_id'][];
}

// User Schema
const UserSchema: Schema = new Schema({
  dni: { type: String, unique: true, required: true },
  name: { type: String, required: true },
  password: { type: String, required: true },
  role: { type: String, default: "client" },
  accounts: [{ type: Schema.Types.ObjectId, ref: 'Account' }],
});

// User Model
const User: Model<IUser> = mongoose.model<IUser>('User', UserSchema);

export { User, IUser };
