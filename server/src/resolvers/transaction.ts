import { ITransaction, Transaction } from '../model/transaction';
import { Account } from "../model/account";
import  { Types } from "mongoose";
import { Context } from "../utils/context";
import { getUserId } from "../utils/jwt";
import { User } from "../model/user";


async function me(context: Context) {
  const userId = getUserId(context);

  if (!userId) {
    throw new Error("User not authenticated");
  }

  const user = await User.findById(new Types.ObjectId(userId));
  if (!user) {
    throw new Error("User not found");
  }

  return user;
}

export const transactionResolvers = {
  Query: {
    getTransactions : async (context: Context): Promise<ITransaction[]> => {
      try {
        
        const currentUser = await me(context);
        if(!currentUser){
          throw("User not authenticated")
        }
        const transactions = await Transaction.find().sort({ createDate: -1 });
        return transactions;
      } catch (error) {
        console.error('Error fetching transactions:', error);
        throw new Error('Error fetching transactions');
      }
    },
  },

  Mutation: {
    addTransaction: async (_root: any, args: { input: { operation: string; import: number; accountNumber: string } }, context: Context) => {
      const { operation, import: importAmount, accountNumber } = args.input;
      
      const currentUser = await me(context);
      if(!currentUser){
        throw("User not authenticated")
      }
      
       const account = await Account.findOne({ number_account: accountNumber });
       if (!account) {
         throw new Error('Account not found');
       }

    
      const transaction = new Transaction({
        balance: account.balance,
        operation,
        import: importAmount,
        create_date: new Date(),
      });
      const savedTransaction = await transaction.save();

      account.transactions.push(savedTransaction._id);
      await account.save();

      return savedTransaction;
    },
  },
};
