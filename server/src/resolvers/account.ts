import { Types } from "mongoose";
import { Account, IAccount } from "../model/account";
import { print } from "graphql";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { User } from "../model/user";


function generateUniqueAccountNumber(): string {
  const now = new Date();
  const month = String(now.getMonth() + 1).padStart(2, '0'); // Meses de 0-11, así que sumamos 1
  const day = String(now.getDate()).padStart(2, '0');
  const hour = String(now.getHours()).padStart(2, '0');
  const minute = String(now.getMinutes()).padStart(2, '0');
  
  return `${month}${day}${hour}${minute}`;
}



interface AddAccountInput {
    owner_dni: string;
    owner_name: string;
    number_account: string;
    balance: number;
    active: boolean;
  }

  interface TransferInput {
    accountOrigen: string;
    accountDestin: string;
    importNumber: number;
  }
  
  interface TransferResult {
    success: boolean;
    message?: string;
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
          },
          
         removeAccount: async (_root: any, args: any) => {
             const deletionResult = await Account.deleteOne({ number_account: args.number_account });
             return deletionResult.deletedCount;
         },

        makeTransfer: async (_root: any, { input }: { input: TransferInput }): Promise<any> => {
          try {
            // Encuentra las cuentas por su número de cuenta
            const accountOrigenDoc = await Account.findOne({ accountNumber: input.accountOrigen });
            const accountDestinDoc = await Account.findOne({ accountNumber: input.accountDestin });
    
            if (!accountOrigenDoc || !accountDestinDoc) {
              return {
                success: false,
                message: 'Una o ambas cuentas no existen.',
              };
            }
    
            // Convierte el importe a transferir a un número válido
            const importNumber = input.importNumber;
    
            // Verifica si importNumber es un número válido
            if (isNaN(importNumber) || importNumber <= 0) {
              return {
                success: false,
                message: 'El importe a transferir debe ser un número válido mayor que cero.',
              };
            }
    
            // Verifica si hay suficiente saldo en la cuenta de origen
            console.log("Saldo actual de la cuenta de origen:", accountOrigenDoc.balance);
            console.log("Importe de la transacción a realizar:", importNumber);

            if (accountOrigenDoc.balance < importNumber) {
              return {
                success: false,
                message: 'Saldo insuficiente en la cuenta de origen.',
              };
            }
    
            // Realiza la transferencia
            accountOrigenDoc.balance -= importNumber;
            accountDestinDoc.balance += importNumber;
    
            // Guarda los cambios en la base de datos
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
