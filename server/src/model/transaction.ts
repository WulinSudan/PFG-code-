import mongoose, { Document, Schema, Model } from 'mongoose';

// Interface for Transaction
interface ITransaction extends Document {
  operation: string;
  import: number;
  //create_date: Date; // Asegúrate de que este campo es de tipo Date
}

// Transaction Schema
const TransactionSchema: Schema = new Schema({
  operation: { type: String, required: true },
  import: { type: Number, required: true },
  //create_date: { type: Date }, // Usa Date para manejar fechas
});

// Transaction Model
const Transaction: Model<ITransaction> = mongoose.model<ITransaction>('Transaction', TransactionSchema);

export { Transaction, ITransaction };
