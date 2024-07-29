import mongoose, { Document, Schema, Model } from 'mongoose';

function getUtcPlusTwoDate() {
  const now = new Date();
  // Obtener el tiempo en milisegundos y añadir dos horas (2 * 60 * 60 * 1000 milisegundos)
  const utcPlusTwoTime = now.getTime() + (2 * 60 * 60 * 1000);
  // Crear un nuevo objeto Date con el tiempo UTC+2
  return new Date(utcPlusTwoTime);
}

// Interface for Account
interface IAccount extends Document {
  owner_dni: string;
  owner_name: string;
  number_account: string; // Debe ser un string de 10 caracteres numéricos no repetitivos
  balance: number; // Puede ser un número decimal
  active: boolean;
  key_to_charge: string;
  key_to_pay: string;
  maximum_amount_once: number;
  maximun_amount_day: number;
  description:string;
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
    // Getter para formatear el balance a 2 decimales al obtenerlo del modelo
    get: (value: number) => parseFloat(value.toFixed(2)),
    // Setter para asegurar que se almacene con 2 decimales
    set: (value: number) => parseFloat(value.toFixed(2)),
  },
  active: { type: Boolean, required: true },
  key_to_charge: { type: String, required: true},
  key_to_pay: { type: String, required: true},
  maximum_amount_once: { type: Number, requered:true },
  maximum_amount_day: { type: Number, requered:true },
  description: { type: String, requered:false },
});

// Account Model
const Account: Model<IAccount> = mongoose.model<IAccount>('Account', AccountSchema);

export { Account, IAccount };
