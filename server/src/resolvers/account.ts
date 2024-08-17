import { Account, IAccount } from "../model/account";
import mongoose, { Types } from "mongoose";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { comparePassword, hashPassword } from "../utils/crypt";
import { User, IUser} from "../model/user";
import { Transaction } from "../model/transaction";
import { ContextFunction } from "@apollo/server";
import fs from 'fs-extra';
import path from 'path';


const logFilePath = path.join(__dirname, '../../logs/accounts.txt');

// Función para escribir logs en el archivo
const writeLog = async (message: string) => {
  try {
    await fs.appendFile(logFilePath, `${message}\n`);
  } catch (err) {
    console.error('Error al escribir en el archivo de log:', err);
  }
};

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

async function findUser(accountNumber: string): Promise<IUser | null> {
  try {
    // Encuentra la cuenta usando el número de cuenta
    const account = await Account.findOne({ accountNumber }).exec();
    
    if (!account) {
      console.log('No se encontró ninguna cuenta con el número proporcionado.');
      return null;
    }

    // Encuentra el usuario que tiene la cuenta en su lista de cuentas
    const user = await User.findOne({ accounts: account._id }).exec();

    return user;
  } catch (error) {
    console.error('Error al buscar el usuario:', error);
    throw new Error('No se pudo encontrar el usuario.');
  }
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

    // Obtener información de las cuentas del usuario autenticado
    getUserAccounts: async (_root: any, context: Context) => {
      try {
        // Obtener el usuario autenticado usando la función `me`
        const currentUser = await me(context);
        console.log(`Usuario autenticado: ${currentUser.name}`);

        const accountIds = currentUser.accounts;

        // Verificar si el usuario tiene cuentas asociadas
        if (!Array.isArray(accountIds) || accountIds.length === 0) {
          return [];
        }

        // Buscar todas las cuentas asociadas al usuario
        const accounts = await Account.find({ _id: { $in: accountIds } });

        // Filtrar las cuentas que tienen un nombre de propietario válido
        const validAccounts = accounts.filter(account => account.owner_name);

        return validAccounts;
      } catch (error) {
        console.error('Error al obtener las cuentas del usuario:', error);
        throw new Error('No se pudo obtener la información de las cuentas del usuario.');
      }
    },



    // Obtener información de las cuentas del usuario por DNI
    getUserAccountsInfoByDni: async (_root: any, { dni }: { dni: string }, context: Context) => {

      const currentUser = await me(context);
      console.log(currentUser.name);

      try {
        const user = await User.findOne({ dni });
        if (!user) {
          throw new Error('User not found');
        }

        console.log(user.name);

        const accountIds = user.accounts;

        if (!Array.isArray(accountIds) || accountIds.length === 0) {
          return [];
        }

        const accounts = await Account.find({ _id: { $in: accountIds } });
        const validAccounts = accounts.filter(account => account.owner_name);

        return validAccounts;
      } catch (error) {
        console.error('Error fetching user accounts info by DNI:', error);
        throw new Error('Error fetching user accounts info by DNI');
      }
    },

    // Obtener el estado de una cuenta por su número
    getAccountStatus: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context) => {
      
      const currentUser = await me(context);

      try {
        const account = await findAccount(accountNumber);

        const logMessage = `${new Date().toISOString()} - Operación consulta: get account ${accountNumber} status`;
        currentUser.logs.push(logMessage);
        currentUser.save();

        return account?.active || false; 
      } catch (error) {
        console.error('Error al obtener el estado de la cuenta:', error);
        throw new Error('No se pudo obtener el estado de la cuenta.');
      }
    },

    // Obtener el saldo de una cuenta por su número
    getAccountBalance: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context) => {
      const currentUser = await me(context);

      try {
        const account = await findAccount(accountNumber);

        const logMessage = `${new Date().toISOString()} - Operación consulta: get account ${accountNumber} balance`;
        currentUser.logs.push(logMessage);
        currentUser.save();

        return account?.balance || false; 
      } catch (error) {
        console.error('Error al obtener el estado de la cuenta:', error);
        throw new Error('No se pudo obtener el estado de la cuenta.');
      }
    },

    // no utiliza
    getMaxPayDay: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context) => {
      const currentUser = await me(context);

      try {
        const account = await findAccount(accountNumber);

        const logMessage = `${new Date().toISOString()} - Operación consulta: get account ${accountNumber} max pay day`;
        currentUser.logs.push(logMessage);
        currentUser.save();

        return account?.maximum_amount_day || false; 
      } catch (error) {
        console.error('Error al obtener el estado de la cuenta:', error);
        throw new Error('No se pudo obtener el estado de la cuenta.');
      }
    },

    // Obtener las transacciones asociadas a una cuenta
    getAccountTransactions: async (_root: any, { n_account }: { n_account: string }, context: Context) => {

      const currentUser = await me(context);

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
      try {
        // Obtener el usuario autenticado
        const currentUser = await me(context);
    
        // Buscar la cuenta con el número de cuenta proporcionado y verificar que pertenezca al usuario actual
        const account = await Account.findOne({
          number_account: accountNumber,
          userId: new Types.ObjectId(currentUser._id)
        });
    
        if (!account) {
          throw new Error('Account not found');
        }
    
        // Registrar la operación en los logs del usuario
        const logMessage = `${new Date().toISOString()} - Operación consulta: get account ${accountNumber} key`;
        currentUser.logs.push(logMessage);
    
        // Guardar los cambios en los logs del usuario
        await currentUser.save();
    
        // Devolver la llave de la cuenta
        return account.key_to_pay;
      } catch (error) {
        console.error('Error al obtener la llave de pago de la cuenta:', error);
        throw new Error('No se pudo obtener la llave de pago de la cuenta.');
      }
    },
    

    // Buscar una cuenta por su número
    findAccount: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context) => {
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
    // no utiliza
    getAllAccounts: async (): Promise<IAccount[]> => {
      try {
        return await Account.find();
      } catch (error) {
        console.error('Error fetching accounts:', error);
        throw new Error('Error fetching accounts');
      }
    },

    // Contar el número total de cuentas
    // no utiliza
    countAccount: async () => {
      return await Account.countDocuments();
    },
  },

  Mutation: {
    // Establecer la descripción de una cuenta
    setAccountDescription: async (_root: any, { accountNumber, description }: { accountNumber: string, description: string }, context:Context): Promise<string> => {
      try {

        const currentUser = await me(context);

        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }

        await Account.updateOne(
          { number_account: accountNumber },
          { $set: { description } }
        );

        
        const logMessage = `${new Date().toISOString()} - Mutation operation: set account  ${accountNumber} description`;
        currentUser.logs.push(logMessage);
        await currentUser.save();

        return description;
      } catch (error) {
        console.error("Error setting new description:", error);
        throw new Error("Failed to set account description");
      }
    },

    // Cambiar el estado de una cuenta
    // des de la cuenta, tengo que tener el usuario

    changeAccountStatus: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context): Promise<boolean> => {
      
      console.log("En changeAccountStatus");

      try {
        // Obtener el usuario actual
        const currentUser = await me(context);
    
        // Buscar la cuenta por número
        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }
    
        // Alternar el estado de la cuenta
        const newStatus = !account.active; // Cambia el estado actual
        await Account.updateOne(
          { number_account: accountNumber },
          { $set: { active: newStatus } }
        );
    
        // Verificar si la cuenta ha sido actualizada
        const updatedAccount = await Account.findOne({ number_account: accountNumber });
        if (!updatedAccount) {
          throw new Error("Failed to retrieve updated account status");
        }
    
        // Registrar la operación en los logs del usuario actual
        const logMessage = `${new Date().toISOString()} - Mutation operation: change account ${accountNumber} status to ${newStatus} by ${currentUser.name}`;
        currentUser.logs.push(logMessage);
        await currentUser.save();

        await writeLog(logMessage);
    
        // Retornar el estado actualizado
        return updatedAccount.active;
      } catch (error) {
        console.error("Error setting account active status:", error);
        throw new Error("Failed to update account status");
      }
    },
    

    // Establecer el máximo importe de pago permitido
    setMaxPayImport: async (_root: any, { accountNumber, maxImport }: { accountNumber: string, maxImport: number }, context:Context): Promise<number> => {
      try {
        const currentUser = await me(context);
        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }

        await Account.updateOne(
          { number_account: accountNumber },
          { $set: { maximum_amount_once: maxImport } }
        );

        const logMessage = `${new Date().toISOString()} - Mutation operation: set accounts max pay import in ${maxImport}`;
        currentUser.logs.push(logMessage);
        await currentUser.save();

        return maxImport;
      } catch (error) {
        console.error("Error setting new maxPayImport:", error);
        throw new Error("Failed to set max pay import");
      }
    },

    // Agregar una cuenta a un usuario por DNI
    // no utiliza
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
        const currentUser = await me(context);

        const newAccount = new Account({
          owner_dni: currentUser.dni,
          owner_name: currentUser.name,
          number_account: generateUniqueAccountNumber(),
          balance: 10.5,
          active: true,
          key_to_pay: "1234567890123456",
          maximum_amount_once: 50,
          maximum_amount_day: 500,
          description: "cuenta nomina",
        });

        await newAccount.save();

        currentUser.accounts.push(newAccount._id);

        const logMessage = `${new Date().toISOString()} - Mutation operation: add accounts`;
        currentUser.logs.push(logMessage);
        
        await currentUser.save();

        return newAccount;
      } catch (error) {
        throw new Error('Error creating account for the user');
      }
    },

    // Eliminar una cuenta
    // falta utilizar me
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

      const logMessage = `${new Date().toISOString()} - Mutation operation: remove user accounts ${number_account}`;
      user.logs.push(logMessage);
      await user.save();

      if (deletionResult.deletedCount === 0) {
        throw new Error('Failed to delete the account.');
      }

      user.accounts = user.accounts.filter(accountId => !accountId.equals(account._id));
      await user.save();

      console.log('Account deleted successfully');
      return deletionResult.deletedCount;
    },

    // Realizar una transferencia entre cuentas
    // pendent de fer
    makeTransfer: async (_root: any, { input }: { input: TransferInput }, context:Context): Promise<any> => {

      console.log("--------------------------------------------");
      console.log(input.accountOrigen);
      console.log(input.accountDestin);
      const userOrigen = await findUser(input.accountOrigen);
      console.log(userOrigen?.name);

      const userDestin = await findUser(input.accountDestin);
      console.log(userDestin?.name);
      console.log("--------------------------------------------");

      const currentUser = await me(context);
      
      // per saber quina compte es del origen
      // a partir de un compte bancari, trobar el usuari



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


        // Registrar la operación en los logs del usuario actual
      const logMessage = `${new Date().toISOString()} - Mutation operation: make transfer from ${input.accountOrigen} to ${input.accountDestin} with value ${importNumber}`;
      
      userDestin?.logs.push(logMessage);
      userOrigen?.logs.push(logMessage);

       await writeLog(logMessage);

        return {
          success: true,
          message: `Transferencia de ${importNumber} unidades realizada correctamente desde ${input.accountOrigen} de ${userOrigen} a ${input.accountDestin} de ${userDestin}.`,
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
