import mongoose, { Document, Schema } from 'mongoose';

// Interface for User
interface IUser extends Document {
  dni: string;
  name: string;
  password: string;
  role: string;
  active: boolean;
  accounts: mongoose.Types.ObjectId[];
  logs: string[];
}

// User Schema
const UserSchema: Schema = new Schema({
  dni: {
    type: String,
    unique: true,
    required: true,
    validate: {
      validator: function(v: string) {
        return /^\d{8}[A-Za-z]$/.test(v);
      },
      message: (props: any) => `${props.value} is not a valid DNI. It must be 8 digits followed by 1 letter.`,
    },
  },
  name: { type: String, required: true },
  password: { type: String, required: true },
  role: { type: String, default: 'client', required: true },
  active: { type: Boolean, default: true, required: true },
  accounts: [{ type: Schema.Types.ObjectId, ref: 'Account' }],
  logs: { type: [String], default: [] },
});

// User Model
const User = mongoose.model<IUser>('User', UserSchema);

export { User, IUser };
