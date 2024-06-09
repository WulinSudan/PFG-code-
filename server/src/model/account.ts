import mongoose, { Document, Schema, Model } from 'mongoose';

// Interface for Account
//prueba branca nueva-prueba
interface IAccount extends Document {
  owner_dni: string;
  owner_name: string;
  number_account: string;
  balance: number;
  active: boolean;
}

// Account Schema
const AccountSchema: Schema = new Schema({
  owner_dni: { type: String, required: true },
  owner_name: { type: String, required: true },
  number_account: { type: String, required: true },
  balance: { type: Number, required: true },
  active: { type: Boolean, required: true },
});

// Account Model
const Account: Model<IAccount> = mongoose.model<IAccount>('Account', AccountSchema);

export { Account, IAccount };
