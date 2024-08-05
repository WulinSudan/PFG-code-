import mongoose, { Document, Schema } from 'mongoose';

// Interface for User
interface IUser extends Document {
  dni: string; // Debe ser un string de 8 dígitos seguidos de 1 letra
  name: string;
  password: string;
  role: string;
  active: Boolean;
  accounts: mongoose.Types.ObjectId[]; // Array de referencias a objetos de tipo Account
}

// User Schema
const UserSchema: Schema = new Schema({
  dni: {
    type: String,
    unique: true,
    required: true,
    validate: {
      validator: function(v: string) {
        // Expresión regular para validar el formato de dni: 8 dígitos seguidos de 1 letra
        return /^\d{8}[A-Za-z]$/.test(v);
      },
      message: (props: any) => `${props.value} no es un DNI válido. Debe tener 8 dígitos seguidos de 1 letra.`,
    },
  },
  name: { type: String, required: true },
  password: { type: String, required: true },
  role: { type: String, default: "client" },
  active: { type: Boolean, default: true },
  accounts: [{ type: Schema.Types.ObjectId, ref: 'Account' }],
});

// User Model
const User = mongoose.model<IUser>('User', UserSchema);

export { User, IUser };
