import { Account, IAccount } from "../model/account";
import mongoose, { Types } from "mongoose";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { comparePassword, hashPassword } from "../utils/crypt";
import { User } from "../model/user";

import { print } from "graphql";

interface TransferInput {
  accountOrigen: string;
  accountDestin: string;
  import: number;
}

// Función local para buscar una cuenta por su número de cuenta
async function findAccount(accountNumber: string): Promise<IAccount | null> {
  try {
    const account = await Account.findOne({ number_account: accountNumber });
    return account;
  } catch (error) {
    console.error('Error al buscar la cuenta:', error);
    throw error;
  }
}

export const accountResolvers = {
  Query: {
    // Resolver para encontrar una cuenta por su número de cuenta
    findAccount: async (_root: any, args: any) => {
      try {
        const account = await Account.findOne({
          number_account: args.accountNumber,
        });

        if (!account) {
          return null;
        }

        return {
          number_account: account.number_account,
          owner_dni: account.owner_dni,
          owner_name: account.owner_name,
          balance: account.balance,
          active: account.active,
        };
      } catch (error) {
        console.error('Error al buscar la cuenta:', error);
        throw error;
      }
    },

    // Resolver para obtener todas las cuentas
    getAllAccounts: async (): Promise<IAccount[]> => {
      try {
        const accounts = await Account.find();
        return accounts;
      } catch (error) {
        console.error('Error fetching accounts:', error);
        throw new Error('Error fetching accounts: ');
      }
    },

    // Resolver para contar el número total de cuentas
    countAccount: async () => {
      return await Account.collection.countDocuments();
    },
  },
  Mutation: {

    
    // Resolver para agregar una cuenta nueva
    addAccount: async (_root: any, { input }: { input: IAccount }): Promise<IAccount> => {
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
    },

    removeAccount : async (_root: any, { number_account }: { number_account: string }, context: Context) => {
      // Obtener el ID del usuario desde el contexto

      const userId = getUserId(context);
      if (!userId) {
        throw new Error('User not authenticated');
      }
    
      // Buscar al usuario por su ID
      const user = await User.findById(new mongoose.Types.ObjectId(userId));
      if (!user) {
        throw new Error('User not found');
      }
    
      // Buscar la cuenta por su número
      const account = await Account.findOne({ number_account: number_account });
      if (!account) {
        throw new Error('Account not found');
      }
    
    
      // Verifica si el saldo es mayor que 0
      if (account.balance > 0) {
        throw new Error('Cannot delete the account because the balance is greater than 0.');
      }
    
      // Eliminar la cuenta de la colección de cuentas
      const deletionResult = await Account.deleteOne({ _id: account._id });
    
      // Verificar si la eliminación fue exitosa
      if (deletionResult.deletedCount === 0) {
        throw new Error('Failed to delete the account.');
      }
    
      // Eliminar la cuenta de la lista de cuentas del usuario
      user.accounts = user.accounts.filter(accountId => !accountId.equals(account._id));
    
      // Guardar el usuario actualizado
      await user.save();
    
      console.log('Account deleted successfully');
      return deletionResult.deletedCount;
    },


    // Resolver para realizar una transferencia entre cuentas
    makeTransfer: async (_root: any, { input }: { input: TransferInput }): Promise<any> => {
      console.log("---------------------------------");
      console.log(input.accountDestin);
      console.log(input.accountOrigen);
      try {
        // Buscar las cuentas de origen y destino utilizando findAccount
        const accountOrigenDoc = await findAccount(input.accountOrigen);
        const accountDestinDoc = await findAccount(input.accountDestin);

        if (!accountOrigenDoc || !accountDestinDoc) {
          return {
            success: false,
            message: 'Una o ambas cuentas no existen.',
          };
        }

        const importNumber = Number(input.import);

        if (isNaN(importNumber) || importNumber <= 0) {
          return {
            success: false,
            message: 'El importe a transferir debe ser un número válido mayor que cero.',
          };
        }

        console.log("cuenta de origen:", accountOrigenDoc.number_account);
        console.log("cuenta de destino:", accountDestinDoc.number_account);
        console.log("Saldo actual de la cuenta de origen:", accountOrigenDoc.balance);
        console.log("Saldo actual de la cuenta de destino:", accountDestinDoc.balance);
        console.log("Importe de la transacción a realizar:", importNumber);

        if (accountOrigenDoc.balance < importNumber) {
          return {
            success: false,
            message: 'Saldo insuficiente en la cuenta de origen.',
          };
        }

        accountOrigenDoc.balance -= importNumber;
        accountDestinDoc.balance += importNumber;

        await accountOrigenDoc.save();
        await accountDestinDoc.save();

        console.log("------------------------------------------------------------------");
        console.log("Saldo actual de la cuenta de origen:", accountOrigenDoc.balance);
        console.log("Saldo actual de la cuenta de destino:", accountDestinDoc.balance);

        return {
          success: true,
          message: `Transferencia de ${importNumber} unidades realizada correctamente desde ${input.accountOrigen} a ${input.accountDestin}.`,
        };
        
      } catch (error) {
        console.error('Error al realizar la transferencia:', error);
        return {
          success: false,
          message: 'Error al realizar la transferencia. Por favor, inténtalo de nuevo más tarde.',
        };
      }
    },
  },
};
