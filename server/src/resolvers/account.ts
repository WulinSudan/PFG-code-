import { Account, IAccount } from "../model/account";
import { Types } from "mongoose";

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

    // Resolver para eliminar una cuenta por su número de cuenta
    removeAccount: async (_root: any, args: any) => {
      try {
        // Encuentra la cuenta por su número de cuenta para verificar el saldo
        //const account = await Account.findOne({ number_account: args.number_account });
        const account = await findAccount(args.number_account);

        if (!account) {
          throw new Error(`No se encontró la cuenta con el número de cuenta ${args.number_account}`);
        }

        // Verifica si el saldo es mayor que 0
        if (account.balance > 0) {
          throw new Error('No se puede eliminar la cuenta porque el saldo es mayor que 0.');
        }

        // Si el saldo es 0, procede con la eliminación de la cuenta
        const deletionResult = await Account.deleteOne({ number_account: args.number_account });

        if (deletionResult.deletedCount > 0) {
          console.log('Cuenta eliminada exitosamente');
        }

        return deletionResult.deletedCount;
      } catch (error) {
        console.error("Error removing account:", error);
        throw new Error('Error removing account: ');
      }
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
