import { Account, IAccount } from "../model/account";
import mongoose, { Types } from "mongoose";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { comparePassword, hashPassword } from "../utils/crypt";
import { User } from "../model/user";
import { Transaction } from "../model/transaction";

// Genera un número de cuenta único basado en la fecha y hora actuales
function generateUniqueAccountNumber(): string {
  const now = new Date();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  const hour = String(now.getHours()).padStart(2, '0');
  const minute = String(now.getMinutes()).padStart(2, '0');
  const second = String(now.getSeconds()).padStart(2, '0');
  
  const aux = `${month}${day}${hour}${minute}${second}`;
  console.log(aux);
  return aux;
}

interface AddAccountInput {
  owner_dni: string;
  owner_name: string;
}

interface AddAccountArgs {
  input: AddAccountInput;
}

interface TransferInput {
  accountOrigen: string;
  accountDestin: string;
  import: number;
}

// Función local para buscar una cuenta por su número de cuenta
async function findAccount(accountNumber: string): Promise<IAccount | null> {
  try {
    return await Account.findOne({ number_account: accountNumber });
  } catch (error) {
    console.error('Error al buscar la cuenta:', error);
    throw error;
  }
}

// Resolver para obtener la información del usuario autenticado
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

export const accountResolvers = {
  Query: {
    // Obtener información de las cuentas del usuario por DNI
    getUserAccountsInfoByDni: async (_root: any, { dni }: { dni: string }, context: Context) => {
      try {
        const user = await User.findOne({ dni });
        if (!user) {
          throw new Error('User not found');
        }

        const accountIds = user.accounts;

        if (!Array.isArray(accountIds) || accountIds.length === 0) {
          return [];
        }

        const accounts = await Account.find({ _id: { $in: accountIds } });
        const validAccounts = accounts.filter(account => account.owner_name);

        const logMessage = `${new Date().toISOString()} - Operación consulta: get user accounts info by dni`;
        user.logs.push(logMessage);

        await user.save();

        return validAccounts;
      } catch (error) {
        console.error('Error fetching user accounts info by DNI:', error);
        throw new Error('Error fetching user accounts info by DNI');
      }
    },

    // Obtener el estado de una cuenta por su número
    getAccountStatus: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context) => {
      
      const user = me(context);

      try {
        const account = await findAccount(accountNumber);
        return account?.active || false; 
      } catch (error) {
        console.error('Error al obtener el estado de la cuenta:', error);
        throw new Error('No se pudo obtener el estado de la cuenta.');
      }
    },

    // Obtener el saldo de una cuenta por su número
    getAccountBalance: async (_root: any, { accountNumber }: { accountNumber: string }) => {
      const account = await Account.findOne({ number_account: accountNumber });
      return account?.balance;
    },

    // Obtener el máximo importe diario permitido para una cuenta
    getMaxPayDay: async (_root: any, { accountNumber }: { accountNumber: string }) => {
      const account = await Account.findOne({ number_account: accountNumber });
      return account?.maximum_amount_day;
    },

    // Obtener las transacciones asociadas a una cuenta
    getAccountTransactions: async (_root: any, { n_account }: { n_account: string }) => {
      try {
        const account = await Account.findOne({ number_account: n_account });
        if (!account) {
          throw new Error('Account not found');
        }

        const transactionIds = account.transactions;
        const transactions = await Transaction.find({ _id: { $in: transactionIds } });
        const validTransactions = transactions.filter(transaction => 
          transaction.operation !== null && 
          transaction.create_date !== undefined && 
          transaction.import !== undefined
        );

        return validTransactions;
      } catch (error) {
        console.error('Error fetching transactions info by account number:', error);
        throw new Error('Error fetching transactions info by account number');
      }
    },

    // Obtener la clave de pago de una cuenta
    getAccountPayKey: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context): Promise<string> => {
      console.log(`En la función getAccountPayKey, buscar la llave de la cuenta: ${accountNumber}`);

      const userId = getUserId(context);
      if (!userId) {
        throw new Error('User not authenticated');
      }

      const account = await Account.findOne({ number_account: accountNumber, userId: new Types.ObjectId(userId) });
      if (!account) {
        throw new Error('Account not found');
      }

      console.log(`En la función getAccountPayKey, llave encontrada: ${account.key_to_pay}`);
      return account.key_to_pay;
    },

    // Buscar una cuenta por su número
    findAccount: async (_root: any, { accountNumber }: { accountNumber: string }) => {
      try {
        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          return null;
        }

        return {
          number_account: account.number_account,
          owner_dni: account.owner_dni,
          owner_name: account.owner_name,
          balance: account.balance,
          active: account.active,
          maximum_amount_day: account.maximum_amount_day,
          maximum_amount_once: account.maximum_amount_once,
        };
      } catch (error) {
        console.error('Error al buscar la cuenta:', error);
        throw error;
      }
    },

    // Obtener todas las cuentas
    getAllAccounts: async (): Promise<IAccount[]> => {
      try {
        return await Account.find();
      } catch (error) {
        console.error('Error fetching accounts:', error);
        throw new Error('Error fetching accounts');
      }
    },

    // Contar el número total de cuentas
    countAccount: async () => {
      return await Account.countDocuments();
    },
  },

  Mutation: {
    // Establecer la descripción de una cuenta
    setAccountDescription: async (_root: any, { accountNumber, description }: { accountNumber: string, description: string }): Promise<string> => {
      try {
        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }

        await Account.updateOne(
          { number_account: accountNumber },
          { $set: { description } }
        );

        return description;
      } catch (error) {
        console.error("Error setting new description:", error);
        throw new Error("Failed to set account description");
      }
    },

    // Cambiar el estado de una cuenta
    changeAccountStatus: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context): Promise<boolean> => {
      try {
        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }

        const newStatus = !account.active;
        await Account.updateOne(
          { number_account: accountNumber },
          { $set: { active: newStatus } }
        );

        const updatedAccount = await Account.findOne({ number_account: accountNumber });
        return updatedAccount ? updatedAccount.active : false;
      } catch (error) {
        console.error("Error setting account active status:", error);
        throw new Error("Failed to update account status");
      }
    },

    // Establecer el máximo importe de pago permitido
    setMaxPayImport: async (_root: any, { accountNumber, maxImport }: { accountNumber: string, maxImport: number }): Promise<number> => {
      try {
        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }

        await Account.updateOne(
          { number_account: accountNumber },
          { $set: { maximum_amount_once: maxImport } }
        );

        return maxImport;
      } catch (error) {
        console.error("Error setting new maxPayImport:", error);
        throw new Error("Failed to set max pay import");
      }
    },

    // Agregar una cuenta a un usuario por DNI
    addAccountByUser: async (_root: any, { input: { owner_dni, owner_name } }: AddAccountArgs): Promise<IAccount> => {
      try {
        const newAccount = new Account({
          owner_dni,
          owner_name,
          number_account: generateUniqueAccountNumber(),
          balance: 10.5,
          active: true,
          key_to_pay: "1234567890123456",
          maximum_amount_once: 50,
          maximum_amount_day: 500,
          description: "cuenta nomina",
        });

        await newAccount.save();

        const user = await User.findOne({ dni: owner_dni });
        if (!user) {
          throw new Error('User not found');
        }

        user.accounts.push(newAccount._id);
        await user.save();

        return newAccount;
      } catch (error) {
        throw new Error('Error creating account');
      }
    },

    // Agregar una cuenta al usuario autenticado
    addAccountByAccessToken: async (_root: any, _args: any, context: Context): Promise<IAccount> => {
      try {
        const userId = getUserId(context);
        if (!userId) {
          throw new Error('User not authenticated');
        }

        const user = await User.findById(new Types.ObjectId(userId));
        if (!user) {
          throw new Error("User not found");
        }

        const newAccount = new Account({
          owner_dni: user.dni,
          owner_name: user.name,
          number_account: generateUniqueAccountNumber(),
          balance: 10.5,
          active: true,
          key_to_pay: "1234567890123456",
          maximum_amount_once: 50,
          maximum_amount_day: 500,
          description: "cuenta nomina",
        });

        await newAccount.save();

        user.accounts.push(newAccount._id);
        await user.save();

        return newAccount;
      } catch (error) {
        throw new Error('Error creating account for the user');
      }
    },

    // Eliminar una cuenta
    removeAccount: async (_root: any, { number_account }: { number_account: string }, context: Context) => {
      const userId = getUserId(context);
      if (!userId) {
        throw new Error('User not authenticated');
      }

      const user = await User.findById(new mongoose.Types.ObjectId(userId));
      if (!user) {
        throw new Error('User not found');
      }

      const account = await Account.findOne({ number_account });
      if (!account) {
        throw new Error('Account not found');
      }

      if (account.balance > 0) {
        throw new Error('Cannot delete the account because the balance is greater than 0.');
      }

      const deletionResult = await Account.deleteOne({ _id: account._id });

      if (deletionResult.deletedCount === 0) {
        throw new Error('Failed to delete the account.');
      }

      user.accounts = user.accounts.filter(accountId => !accountId.equals(account._id));
      await user.save();

      console.log('Account deleted successfully');
      return deletionResult.deletedCount;
    },

    // Realizar una transferencia entre cuentas
    makeTransfer: async (_root: any, { input }: { input: TransferInput }): Promise<any> => {
      try {
        const accountOrigenDoc = await findAccount(input.accountOrigen);
        const accountDestinDoc = await findAccount(input.accountDestin);

        if (!accountOrigenDoc || !accountDestinDoc) {
          return {
            success: false,
            message: 'Una o ambas cuentas no existen.',
          };
        }

        if (accountOrigenDoc._id.equals(accountDestinDoc._id)) {
          return {
            success: false,
            message: 'No se puede realizar transferencia en la misma cuenta',
          };
        }

        const importNumber = Number(input.import);

        if (isNaN(importNumber) || importNumber <= 0) {
          return {
            success: false,
            message: 'El importe a transferir debe ser un número válido mayor que cero.',
          };
        }

        if (accountOrigenDoc.balance < importNumber) {
          return {
            success: false,
            message: 'Saldo insuficiente en la cuenta de origen.',
          };
        }

        if (importNumber > accountOrigenDoc.maximum_amount_once) {
          return {
            success: false,
            message: 'Supera el máximo permitido para una sola transacción.',
          };
        }

        accountOrigenDoc.balance -= importNumber;
        accountDestinDoc.balance += importNumber;

        await accountOrigenDoc.save();
        await accountDestinDoc.save();

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
