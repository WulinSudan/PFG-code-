import { Account } from '../model/account';
import { ITransaction, Transaction } from '../model/transaction';

export const transactionResolvers = {
  Query: {
    // Aquí puedes definir tus resolvers de consulta
    getTransactions: async (): Promise<ITransaction[]> => {
      try {
        const transactions = await Transaction.find();
        return transactions;
      } catch (error) {
        console.error('Error fetching transaction:', error);
        throw new Error('Error fetching transaction: ');
      }
    },

  },
  Mutation: {
    addTransaction: async (_root: any, args: { input: { operation: string; import: number; accountNumber: string } }) => {
      const { operation, import: importAmount, accountNumber } = args.input;
      
       // Encuentra la cuenta y añade la transacción
       const account = await Account.findOne({ number_account: accountNumber });
       if (!account) {
         throw new Error('Account not found');
       }

      const now = new Date(); 
      // Crea y guarda la nueva transacción
      const transaction = new Transaction({
        operation,
        import: importAmount,
        create_date: now,
      });
      const savedTransaction = await transaction.save();

      // Agrega el ID de la transacción a la lista de transacciones de la cuenta
      account.transactions.push(savedTransaction._id);
      await account.save();

      return savedTransaction;
    },
  },
};
