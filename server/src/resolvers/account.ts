import { Account, IAccount } from "../model/account";
import mongoose, { Types } from "mongoose";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { comparePassword, hashPassword } from "../utils/crypt";
import { User } from "../model/user";

import { print } from "graphql";
import { UpdateResult } from "mongodb";


function generateUniqueAccountNumber(): string {
  const now = new Date();
  //const year = String(now.getFullYear()).slice(-2);
  const month = String(now.getMonth() + 1).padStart(2, '0'); // Meses de 0-11, así que sumamos 1
  const day = String(now.getDate()).padStart(2, '0');
  const hour = String(now.getHours()).padStart(2, '0');
  const minute = String(now.getMinutes()).padStart(2, '0');
  const second = String(now.getSeconds()).padStart(2,'0');
  
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
    const account = await Account.findOne({ number_account: accountNumber });
    return account;
  } catch (error) {
    console.error('Error al buscar la cuenta:', error);
    throw error;
  }
}

export const accountResolvers = {
  Query: {

          //seria mejor dejar en account
          getAccountPayKey: async (_root: any, args: { accountNumber: string }, context: Context): Promise<string> => {
            const { accountNumber } = args;
            
            console.log(`En la funcion getAccountPaykay, buscar la llave de la cuenta: ${accountNumber}`);

            const userId = getUserId(context); // Función que obtiene el ID del usuario desde el contexto
            if (!userId) {
              throw new Error('User not authenticated');
            }
      
            const account = await Account.findOne({ number_account: accountNumber, userId: new Types.ObjectId(userId) });
            if (!account) {
              throw new Error('Account not found');
            }
            
            console.log(`En la funcion getAccountPayKey, lleve encuentrada: ${account.key_to_pay}`);
            return account.key_to_pay;
          },

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

    // Resolver de GraphQL para establecer el máximo importe de pago
    setMaxPayImport : async (_root: any, { accountNumber, maxImport }: { accountNumber: string, maxImport: number }): Promise<number> => {
      try {

        /*
        const userId = getUserId(context); // Función que obtiene el ID del usuario desde el contexto
        if (!userId) {
          throw new Error('User not authenticated');
        }

        const user = await User.findById(new Types.ObjectId(userId));
        if (!user) {
            throw new Error("User not found");
        }*/
        

        // Buscar la cuenta
        const account = await Account.findOne({ number_account:accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }
        // Actualizar el campo key_to_pay
        await Account.updateOne(
          { number_account: accountNumber },
          { $set: { maximum_amount_once: maxImport} }
        );

        return maxImport;
      } catch (error) {
        console.error("Error setting new maxPayImport:", error);
        throw new Error("Failed to set max pay import");
      }
    },

    addAccountByUser: async (_root: any, { input: { owner_dni, owner_name } }: AddAccountArgs): Promise<IAccount> => {
      try {
        // Create a new account
        const newAccount = new Account({
          owner_dni: owner_dni,
          owner_name: owner_name,
          number_account: generateUniqueAccountNumber(), // Genera un número de cuenta único
          balance: 10.5, // Saldo inicial de 10€
          active: true,
          key_to_pay:"1234567890123456",
          maximum_amount_once:50,
          maximun_amount_day:500,
          description:"cuenta nomina",
        });

        // Save the new account
        await newAccount.save();

        // Find the user by dni
        const user = await User.findOne({ dni: owner_dni });
        if (!user) {
          throw new Error('User not found');
        }

        // Add the new account to the user's accounts array
        user.accounts.push(newAccount._id);
        await user.save();

        return newAccount;
      } catch (error) {
        throw new Error('Error creating account: ');
      }
    },


    addAccountByAccessToken: async (_root: any, _args: any, context: Context): Promise<IAccount> => {
      try {

        const userId = getUserId(context); // Función que obtiene el ID del usuario desde el contexto
        if (!userId) {
          throw new Error('User not authenticated');
        }

        const user = await User.findById(new Types.ObjectId(userId));
        if (!user) {
            throw new Error("User not found");
        }
  

        // Crear una nueva cuenta con saldo inicial de 10€
        const newAccount = new Account({
          owner_dni: user.dni,
          owner_name: user.name,
          number_account: generateUniqueAccountNumber(), // Genera un número de cuenta único
          balance: 10.5, // Saldo inicial de 10€
          active: true,
          key_to_pay:"1234567890123456",
          maximum_amount_once:50,
          maximun_amount_day:500,
          description:"cuenta nomina",
        });
  
        await newAccount.save();

        // Asociar la cuenta al usuario
        user.accounts.push(newAccount._id);
        await user.save();

        return newAccount;
      } catch (error) {
        throw new Error(`Error al crear cuenta para el usuario`);
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

        if (accountOrigenDoc == accountDestinDoc) {
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

        console.log("cuenta de origen:", accountOrigenDoc.number_account);
        console.log("cuenta de destino:", accountDestinDoc.number_account);
        console.log("Saldo actual de la cuenta de origen:", accountOrigenDoc.balance);
        console.log("Saldo actual de la cuenta de destino:", accountDestinDoc.balance);
        console.log("Importe de la transacción a realizar:", importNumber);

        if (accountOrigenDoc.balance < importNumber) {
          console.log(`quiero que se entre en aqui`);
          return {
            success: false,
            message: 'Saldo insuficiente en la cuenta de origen.',
          };
        }


        if (importNumber > accountOrigenDoc.maximum_amount_once) {
          return {
            success: false,
            message: 'Supera el màximo establecido del dia',
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
