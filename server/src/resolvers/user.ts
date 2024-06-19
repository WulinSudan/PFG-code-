import { Types } from "mongoose";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { comparePassword, hashPassword } from "../utils/crypt";
import { User } from "../model/user";
import { Account, IAccount } from "../model/account";
import { print } from "graphql";


function generateUniqueAccountNumber(): string {
  const now = new Date();
  const year = String(now.getFullYear()).slice(-2);
  const month = String(now.getMonth() + 1).padStart(2, '0'); // Meses de 0-11, así que sumamos 1
  const day = String(now.getDate()).padStart(2, '0');
  const hour = String(now.getHours()).padStart(2, '0');
  const minute = String(now.getMinutes()).padStart(2, '0');
  
  const aux = `${year}${month}${day}${hour}${minute}`;
  console.log(aux);
  return aux;
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
                return {
                    name:user.name
                };
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
        addAccountByUser: async (_root: any, { input: { owner_dni, owner_name, number_account, balance, active } }: AddAccountArgs): Promise<IAccount> => {
            try {
              // Create a new account
              const newAccount = new Account({
                owner_dni,
                owner_name,
                number_account,
                balance,
                active,
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
    },
};
