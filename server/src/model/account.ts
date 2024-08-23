import mongoose, { Document, Schema, Model } from 'mongoose';
import { ITransaction } from './transaction';

// Interface for Account
interface IAccount extends Document {
  owner_dni: string;
  owner_name: string;
  number_account: string;
  balance: number;
  active: boolean;
  key_to_pay: string;
  maximum_amount_once: number;
  maximum_amount_day: number;
  description: string;
  transactions: mongoose.Types.ObjectId[];
}

// Account Schema
const AccountSchema: Schema = new Schema({
  owner_dni: { type: String, required: true },
  owner_name: { type: String, required: true },
  number_account: {
    type: String,
    required: true,
    unique: true,
    validate: {
      validator: function(v: string) {
        return /^\d{10}$/.test(v);
      },
      message: (props: any) => `${props.value} is not a valid account number. It must be 10 digits long.`,
    },
  },
  balance: {
    type: Number,
    required: true,
    default: 0,
    get: (value: number) => parseFloat(value.toFixed(2)),
    set: (value: number) => parseFloat(value.toFixed(2)),
  },
  active: { type: Boolean, required: true },
  key_to_pay: { type: String, required: true },
  maximum_amount_once: { type: Number, required: true },
  maximum_amount_day: { type: Number, required: true },
  description: { type: String, required: false },
  transactions: [{ type: Schema.Types.ObjectId, ref: 'Transaction' }],
});

// Account Model
const Account: Model<IAccount> = mongoose.model<IAccount>('Account', AccountSchema);

export { Account, IAccount };
