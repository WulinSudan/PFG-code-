import { Account } from '../model/account';
import { ITransaction, Transaction } from '../model/transaction';

export const transactionResolvers = {
  Query: {
    // Aquí puedes definir tus resolvers de consulta
    getTransactions : async (): Promise<ITransaction[]> => {
      try {
        // Ordena las transacciones por fecha de creación en orden descendente
        const transactions = await Transaction.find().sort({ createDate: -1 });
        return transactions;
      } catch (error) {
        console.error('Error fetching transactions:', error);
        throw new Error('Error fetching transactions');
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

      // Crea y guarda la nueva transacción
      const transaction = new Transaction({
        balance: account.balance,
        operation,
        import: importAmount,
        create_date: new Date(),
      });
      const savedTransaction = await transaction.save();

      // Agrega el ID de la transacción a la lista de transacciones de la cuenta
      account.transactions.push(savedTransaction._id);
      await account.save();

      return savedTransaction;
    },
  },
};
