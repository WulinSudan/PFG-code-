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
  description: string;
  transactions: mongoose.Types.ObjectId[]; // Array de ObjectId
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
        return /^\d{10}$/.test(v); // Validación para asegurar que sea un string de 10 dígitos
      },
      message: (props: any) => `${props.value} no es un número de cuenta válido. Debe tener 10 dígitos.`,
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
  description: { type: String, required: false },
  transactions: [{ type: Schema.Types.ObjectId, ref: 'Transaction' }], // Lista de referencias a transacciones
});

// Account Model
const Account: Model<IAccount> = mongoose.model<IAccount>('Account', AccountSchema);

export { Account, IAccount };
