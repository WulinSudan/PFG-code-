import { Types } from "mongoose";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { comparePassword, hashPassword } from "../utils/crypt";
import { User } from "../model/user";
import { Account } from "../model/account";
import fs from 'fs-extra';
import path from 'path';


  const logFilePath = path.join(__dirname, '../../logs/users.txt');

  const writeLog = async (message: string) => {
    try {
      await fs.appendFile(logFilePath, `${message}\n`);
    } catch (err) {
      console.error('Error al escribir en el archivo de log:', err);
    }
  }
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

export const userResolvers = {
    Query: {
      
      // try to make functions without input parameters

      getLogs: async (_root: any, { dni }: { dni: string }, context: Context) => {
        // Verify the current user and their role
        const currentUser = await me(context);
        if (currentUser.role !== "admin") {
          throw new Error("Only administrators can view the logs.");
        }
      
        // Find the user by DNI
        const user = await User.findOne({ dni: dni });
      
        if (!user) {
          throw new Error("User not found.");
        }
      
        // Return the user's logs
        return user.logs;
      },   
      getUserInfo : async (_root:any, args:any,context: Context) => {
        
        const currentUser = await me(context);
        if (!currentUser) {
          throw new Error("No user provided");
        }
        const user = await User.findOne({ dni: args.dni });
        if(!user){
          throw("can't fins user");
        }
        return user;
      },
      getUserStatusDni : async (_root: any, { dni }: { dni: string }, context: Context): Promise<boolean> => {
        
        try {
          const user = await User.findOne({ dni: dni });
      
          if (!user) {
              throw new Error("User cannot be found.");
          }
        
          if (typeof user.active !== 'boolean') {
            console.error("User.active is not a boolean:", user.active);
            throw new Error('User active status is not a boolean');
          }
          
          console.log("User status is", user.active);
          return user.active;
        } catch (error) {
          console.error(`Error in getUserStatus: ${(error as Error).message}`);
          throw new Error(`Failed to get user status: ${(error as Error).message}`);
        }
      },
      getUserStatus : async (_root: any, context: Context): Promise<boolean> => {
        console.log("Entering getUserStatus name");
      
        try {
          const user = await me(context);
      
          if (!user) {
            console.error("User is undefined or null");
            throw new Error('User not found');
          }
      
          if (typeof user.active !== 'boolean') {
            console.error("User.active is not a boolean:", user.active);
            throw new Error('User active status is not a boolean');
          }
          
          console.log("User status is", user.active);
          return user.active;
        } catch (error) {
         
          console.error(`Error in getUserStatus: ${(error as Error).message}`);
          throw new Error(`Failed to get user status: ${(error as Error).message}`);
        }
      },
      getUserName : async (_root: any, context:Context): Promise<string> => {
        try {
          const user = await me(context);
      
          if (!user) {
            throw new Error('User not found');
          }
      
          return user.name;
        } catch (error) {
          throw new Error(`Failed to get user name: ${(error as Error).message}`);
        }
      },
      getUserRole: async (_root: any, { name }: { name: string }): Promise<string> => {
          try {
            const user = await User.findOne({ name });
        
            if (!user) {
              throw new Error('User not found');
            }
        
            return user.role;
          } catch (error) {
            throw new Error(`Failed to get user role: ${(error as Error).message}`);
          }
      },
      getUserAccountCount: async (_root: any, { dni }: { dni: string }) => {
            try {
            
              const user = await User.findOne({ dni });
              if (!user) {
                throw new Error('User not found');
              }
      
              return user.accounts.length;
            } catch (error) {
              console.error('Error fetching user account count by DNI:', error);
              throw new Error('Error fetching user account count by DNI: ');
            }
      },
      getAdmins: async (): Promise<{ name: string; dni: string }[]> => {
            try {
              const users = await User.find({ role: { $ne: 'client' } }).exec();
              
              return users.map(user => ({
                name: user.name,
                dni: user.dni,
                active: user.active,
              }));
            } catch (error) {
              throw new Error(`Error al obtener los usuarios`);
            }
      },
      getUsers: async (): Promise<{ name: string; dni: string }[]> => {
            try {
            
              const users = await User.find({ role: { $ne: 'admin' } }).exec();
              
              return users.map(user => ({
                name: user.name,
                dni: user.dni,
                active: user.active,
              }));
            } catch (error) {
              throw new Error(`Error getting users`);
            }
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
    },

    Mutation: {

      setPassword: async (_root: any, args: { new: string, dni:String}, context: Context): Promise<boolean> => {
        try {
          const currentAdmin = await me(context);
          
          if (!currentAdmin) {
            throw new Error("Admin not found");
          }

          const user = await User.findOne({ dni: args.dni });
          if (!user) {
            throw new Error("User not found");
          }
    
          user.password = await hashPassword(args.new);

          const logMessage = `${new Date().toISOString()} - Mutation operation: ${currentAdmin.name} set password for ${user.name}`;
          currentAdmin.logs.push(logMessage);
          user.logs.push(logMessage);
          await writeLog(logMessage);

          await currentAdmin.save(); 
          await user.save(); 
      
          return true; 
        } catch (error) {
          console.error("Error changing password:", error);
          throw new Error("Failed to change password");
        }
      },
      changePassword: async (_root: any, args: { old: string, new: string }, context: Context): Promise<boolean> => {
        try {
          const currentUser = await me(context);
          
          if (!currentUser) {
            throw new Error("User not found");
          }
      
          const isPasswordMatch = await comparePassword(currentUser.password, args.old);
          
          if (!isPasswordMatch) {
            throw new Error("Incorrect old password");
          }

          currentUser.password = await hashPassword(args.new);


          const logMessage = `${new Date().toISOString()} - Mutation operation: ${currentUser.name} change password`;
          currentUser.logs.push(logMessage);
          await writeLog(logMessage);

          await currentUser.save(); 
      
          return true; 
        } catch (error) {
          console.error("Error changing password:", error);
          throw new Error("Failed to change password"); 
        }
      },
      // cambiar la status de si mateix o per admin
      changeUserStatus: async (_root: any, args: { dni: string }, context: Context): Promise<boolean> => {

        try {
          const user = await User.findOne({ dni: args.dni });
          if (!user) {
            throw new Error("User does not exist");
          }

          const newStatus: boolean = !user.active; 
          await User.updateOne(
            { dni: args.dni },
            { $set: { active: newStatus } }
          );
      
          const updatedUser = await User.findOne({ dni: args.dni });

          return updatedUser ? updatedUser.active === true : false; 
        } catch (error) {
          console.error("Error setting user active status:", error);
          throw new Error("Failed to update user status");
        }
      },
      removeUser: async (_root: any, args: any, context: Context) => {

        const currentUser = await me(context);
        if (!currentUser) {
            throw new Error("No user provided");
        }
    
        if (currentUser.dni === args.dni && currentUser.accounts.length === 0) {
            const logMessage = `${new Date().toISOString()} - Mutation operation: removed self`;
            currentUser.logs.push(logMessage);
            await currentUser.save();
    
            const deletionResult = await User.deleteOne({ dni: args.dni });
            return deletionResult.deletedCount;
        }

        const deleteUser = await User.findOne({ dni: args.dni });

        if(deleteUser!.name == "admin"){
          throw("No es pot eliminar administrador ")
        }
        
        if(!deleteUser){
          throw("No exist user")
        }


        if(deleteUser.accounts.length === 0){
          const logMessage = `${new Date().toISOString()} - Mutation operation: removed by ${currentUser.name}`;
          currentUser.logs.push(logMessage);
          await currentUser.save();
  
          const deletionResult = await User.deleteOne({ dni: args.dni });
          return deletionResult.deletedCount;
        }
    
        throw new Error("Cannot delete user");
      },
      signUpAdmin: async (_root: any, { input: {dni,name, password} }: any ) => {

          console.log("En proceso de registrar");
            try {
                const userInput = {
                    dni:dni,
                    name: name,
                    active: true,
                    password: await hashPassword(password),
                    role: "admin",
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
      signUp: async (_root: any, { input: { dni, name, password } }: any, context: Context) => {
  
          let logMessage = '';
        
          try {
            const existingUser = await User.findOne({ dni });
            if (existingUser) {
              logMessage = `${new Date().toISOString()} - Operación fallida: Usuario con DNI ${dni} ya existe.`;
              existingUser.logs.push(logMessage);
              await existingUser.save();
              throw new Error("User already exists");
            }
        
            const userInput = {
              dni: dni,
              name: name,
              active: true,
              password: await hashPassword(password),
            };
        
            const user = new User(userInput);
        
            const newAccount = new Account({
              owner_dni: dni,
              owner_name: name,
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

            logMessage = `${new Date().toISOString()} - Operación: Usuario ${dni} registrado y cuenta ${newAccount.number_account} creada.`;
            user.logs.push(logMessage);
        
            await user.save();
        
            return user;
          } catch (error: any) {
            if (error.code === 11000) {
              throw new Error("User already exists");
            }
            throw error;
          }
      },
      addNewAdmin: async (_root: any, { input: {dni,name, password} }: any ) => {
          try {
              const userInput = {
                  dni:dni,
                  name: name,
                  password: await hashPassword(password),
                  active: true,
                  role: "admin",
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
      loginUser : async (_root: any, { input: { name, password } }: any, context: Context) => {
        try {
    
          const user = await User.findOne({ name }).select("password accounts");
          
          if (!user) {
            throw new Error("Usuario no encontrado");
          }

          const isPasswordValid = await comparePassword(user.password, password);
          if (!isPasswordValid) {
            throw new Error("Usuario o contraseña inválidos");
          }
      
          const accessToken = getAccessToken(
            {
              user: user.id.toString(),
            },
            {
              expiresIn: "1d",
            }
          );
      
          return {
            access_token: accessToken,
            user: user,
          };
      
        } catch (error) {
          console.error(error);
        }
      },
    },
};


