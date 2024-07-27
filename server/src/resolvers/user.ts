import mongoose, { Types } from "mongoose";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { comparePassword, hashPassword } from "../utils/crypt";
import { User } from "../model/user";
import { Account, IAccount } from "../model/account";
import { print } from "graphql";
import { Request, Response } from 'express';



function getUtcPlusTwoDate() {
  const now = new Date();
  // Obtener el tiempo en milisegundos y añadir dos horas (2 * 60 * 60 * 1000 milisegundos)
  const utcPlusTwoTime = now.getTime() + (2 * 60 * 60 * 1000);
  // Crear un nuevo objeto Date con el tiempo UTC+2
  return new Date(utcPlusTwoTime);
}







interface AddAccountInput {
    owner_dni: string;
    owner_name: string;
    number_account: string;
    balance: number;
    active: boolean;
  }
  
  interface AddAccountArgs {
    input: AddAccountInput;
  }

export const userResolvers = {
    Query: {

      //seria mejor dejar en account
      getAccountPayKey: async (_root: any, args: { accountNumber: string }, context: Context): Promise<string> => {
        const { accountNumber } = args;
  
        const userId = getUserId(context); // Función que obtiene el ID del usuario desde el contexto
        if (!userId) {
          throw new Error('User not authenticated');
        }
  
        const account = await Account.findOne({ accountNumber, userId: new Types.ObjectId(userId) });
        if (!account) {
          throw new Error('Account not found');
        }
  
        return account.key_to_pay;
      },


      getAccountChargeKey: async (_root: any, args: { accountNumber: string }, context: Context): Promise<string> => {
        const { accountNumber } = args;
  
        const userId = getUserId(context); // Función que obtiene el ID del usuario desde el contexto
        if (!userId) {
          throw new Error('User not authenticated');
        }
  
        const account = await Account.findOne({ accountNumber, userId: new Types.ObjectId(userId) });
        if (!account) {
          throw new Error('Account not found');
        }
  
        return account.key_to_charge;
      },

        getUserAccountCount: async (_root: any, { dni }: { dni: string }) => {
            try {
              // Buscar al usuario por su DNI
              const user = await User.findOne({ dni });
              if (!user) {
                throw new Error('User not found');
              }
      
              // Devolver el número de cuentas asociadas al usuario
              return user.accounts.length;
            } catch (error) {
              console.error('Error fetching user account count by DNI:', error);
              throw new Error('Error fetching user account count by DNI: ');
            }
          },

        allUsers: async () => {
            const users = await User.find();
            return users.map((user) => {
                return{name:user.name};
            });
        },

        
        me: async (_root: any, _args: any, context: Context) => {
            const userId = getUserId(context);

            if (!userId) {
                throw new Error("User not authenticated");
            }
            const user = await User.findById(new Types.ObjectId(userId));
            if (!user) {
                throw new Error("User not found");
            }
            return user;
        },

        getUserAccountsInfoByDni: async (_root: any, { dni }: { dni: string }) => {
          try {
            // Buscar al usuario por su DNI
            const user = await User.findOne({ dni });
            if (!user) {
              throw new Error('User not found');
            }
        
            // Obtener los IDs de las cuentas asociadas al usuario
            const accountIds = user.accounts;
        
            // Buscar las cuentas por sus IDs
            const accounts = await Account.find({ _id: { $in: accountIds } });

            
        
            // Filtrar cuentas que tienen owner_name no nulo
            const validAccounts = accounts.filter(account => account.owner_name !== null && account.owner_name !== undefined);
        
            // Devolver la información detallada de las cuentas válidas
            return validAccounts;
          } catch (error) {
            console.error('Error fetching user accounts info by DNI:', error);
            throw new Error('Error fetching user accounts info by DNI');
          }
        },
        
        
    },
    Mutation: {

      logoutUser: async (_parent: any, _args: any, context: Context) => {
        try {
          // Aquí puedes manejar cualquier lógica adicional que necesites para el logout
          // Por ejemplo, invalidar el token en una lista negra si es necesario
  
          // Enviar una respuesta de éxito
          return { message: 'Logout successful' };
        } catch (error) {
          // Lanza el error para que GraphQL lo maneje
          throw new Error('Error during logout');
        }
      },
  



        removeUser: async (_root: any, args: any) => {
            const deletionResult = await User.deleteOne({ name: args.name });
            return deletionResult.deletedCount;
        },

        signUp: async (_root: any, { input: {dni,name, password} }: any ) => {
            try {
                const userInput = {
                    dni:dni,
                    name: name,
                    password: await hashPassword(password),
                };

                const user = new User(userInput);
                await user.save();
                return user;
            } catch (error: any) {
                if (error.code === 11000) {
                    throw new Error("User already exist");
                }
                throw error;
            }
        },

        addNewAdmin: async (_root: any, { input: {dni,name, password,role} }: any ) => {
          try {
              const userInput = {
                  dni:dni,
                  name: name,
                  password: await hashPassword(password),
                  role: role,
              };

              const user = new User(userInput);
              await user.save();
              return user;
          } catch (error: any) {
              if (error.code === 11000) {
                  throw new Error("User already exist");
              }
              throw error;
          }
      },


        loginUser: async (_root: any, { input: { name, password } }: any) => {
            const user = await User.findOne({ name }).select("password");
            console.log(user);
            if (!user || !(await comparePassword(user.password, password))) {
                throw new Error("Invalid email or password");
            }

            console.log(user.id);

            return {
                access_token: getAccessToken(
                    {
                        user: user.id.toString(),
                    },
                    {
                        expiresIn: "1d",
                    }
                ),
                user: await User.findById(user.id),
            };
        },
    },
};
function invalidateToken(token: any) {
  throw new Error("Function not implemented.");
}

