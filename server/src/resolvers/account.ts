import { Types } from "mongoose";
import { Account, IAccount } from "../model/account";

interface AddAccountInput {
    owner_dni: string;
    owner_name: string;
    number_account: string;
    balance: number;
    active: boolean;
  }


export const accountResolvers = {
    Query: {
        getAllAccounts: async (): Promise<IAccount[]> => {
            try {
              // Buscar todas las cuentas en la base de datos
              const accounts = await Account.find();
          
              // Devolver las cuentas encontradas
              return accounts;
            } catch (error) {
              console.error('Error fetching accounts:', error);
              throw new Error('Error fetching accounts: ');
            }
          },

        countAccount: async () => {
            return await Account.collection.countDocuments();
        }
    },
    Mutation: {
        addAccount: async (_root: any, { input }: { input: AddAccountInput }): Promise<IAccount> => {
            try {
              const { owner_dni, owner_name, number_account, balance, active } = input;
              
              const account = new Account({
                owner_dni,
                owner_name,
                number_account,
                balance,
                active,
              });
      
              const savedAccount = await account.save();
              return savedAccount;
            } catch (error) {
              console.error("Error adding account:", error);
              throw new Error('Error adding account: ');
            }
          }
        // removeAccount: async (_root: any, args: any) => {
        //     const deletionResult = await Account.deleteOne({ number_account: args.number_account });
        //     return deletionResult.deletedCount;
        // },
    }
};
