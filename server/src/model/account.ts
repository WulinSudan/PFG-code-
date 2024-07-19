import mongoose, { Document, Schema, Model } from 'mongoose';

// Interface for Account
interface IAccount extends Document {
  owner_dni: string;
  owner_name: string;
  number_account: string; // Debe ser un string de 10 caracteres numéricos no repetitivos
  balance: number; // Puede ser un número decimal
  active: boolean;
  key: string;
  qr_create_date: Date
  maximum_amount_once: number
  maximun_amount_day: number

}

// Función para obtener la hora actual ajustada a UTC+2
function getUtcPlusTwoDate(): Date {
  const date = new Date();
  date.setHours(date.getHours() + 2);
  return date;
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
  key: { type: String, required: true, unique: true, default: "dddddddddsakjas_"}, // Nuevo campo 'key'
  qr_create_date: { type: Date, default: getUtcPlusTwoDate }, // Nuevo campo 'createdAt'
  maximum_amount_once: { type: Number, requered:true, default:50},
  maximum_amount_day: { type: Number, requered:true, default:500},

});

// Account Model
const Account: Model<IAccount> = mongoose.model<IAccount>('Account', AccountSchema);

export { Account, IAccount };
