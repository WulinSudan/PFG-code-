import mongoose, { Types } from "mongoose";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { comparePassword, hashPassword } from "../utils/crypt";
import { User } from "../model/user";
import { Account, IAccount } from "../model/account";
import { print } from "graphql";
import { Request, Response } from 'express';
import { getActiveResourcesInfo, throwDeprecation } from "process";
import { accountResolvers } from "./account";
import fs from 'fs-extra';
import path from 'path';



const logFilePath = path.join(__dirname, '../../logs/users.txt');

// Función para escribir logs en el archivo
const writeLog = async (message: string) => {
  try {
    await fs.appendFile(logFilePath, `${message}\n`);
  } catch (err) {
    console.error('Error al escribir en el archivo de log:', err);
  }
};


function getUtcPlusTwoDate() {
  const now = new Date();
  // Obtener el tiempo en milisegundos y añadir dos horas (2 * 60 * 60 * 1000 milisegundos)
  const utcPlusTwoTime = now.getTime() + (2 * 60 * 60 * 1000);
  // Crear un nuevo objeto Date con el tiempo UTC+2
  return new Date(utcPlusTwoTime);
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


interface AddAccountInput {
    owner_dni: string;
    owner_name: string;
    number_account: string;
    balance: number;
    active: boolean;
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

      getLogs: async (_root: any, { dni }: { dni: string }, context: Context) => {
        // Verificar el usuario actual y su rol
        const currentUser = await me(context);
    
        if (currentUser.role !== "admin") {
            throw new Error("Solo los administradores pueden visualizar los logs.");
        }
    
        // Buscar el usuario por DNI
        const user = await User.findOne({ dni: dni });
    
        if (!user) {
            throw new Error("No se puede encontrar el usuario.");
        }
              
        // Retornar los logs del usuario
        return user.logs;
    },
    


       getUserInfo : async (_root:any, args:any) => {
        // Buscar el usuario en la base de datos usando el DNI proporcionado en args
        const user = await User.findOne({ dni: args.dni });
        if(!user){
          throw("can't fins user");
        }

        return user;
      },


      getUserStatusName : async (_root: any, { dni }: { dni: string }, context: Context): Promise<boolean> => {
        
        console.log("Entering getUserStatus");
      
        try {
          // Buscar el usuario por DNI
          const user = await User.findOne({ dni: dni });
      
          if (!user) {
              throw new Error("No se puede encontrar el usuario.");
          }
        
          if (typeof user.active !== 'boolean') {
            console.error("User.active is not a boolean:", user.active);
            throw new Error('User active status is not a boolean');
          }
          
          console.log("User status is", user.active);
          return user.active;
        } catch (error) {
          // Mejora el mensaje de error para incluir detalles
          console.error(`Error in getUserStatus: ${(error as Error).message}`);
          throw new Error(`Failed to get user status: ${(error as Error).message}`);
        }
      },


      getUserStatus : async (_root: any, context: Context): Promise<boolean> => {
        console.log("Entering getUserStatus name");
      
        try {
          const user = await me(context);
      
          // Verifica si el resultado de `me` es `undefined` o si `active` no es un booleano
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
          // Mejora el mensaje de error para incluir detalles
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


          getAdmins: async (): Promise<{ name: string; dni: string }[]> => {
            try {
              // Obtener todos los usuarios, excluyendo al usuario con nombre 'admin'
              //const users = await User.find({ name: { $ne: 'Admin' } }).exec(); 
              const users = await User.find({ role: { $ne: 'client' } }).exec();
              
              // Mapear los resultados a un formato específico
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
              // Obtener todos los usuarios, excluyendo al usuario con nombre 'admin'
              //const users = await User.find({ name: { $ne: 'Admin' } }).exec(); 
              const users = await User.find({ role: { $ne: 'admin' } }).exec();
              
              // Mapear los resultados a un formato específico
              return users.map(user => ({
                name: user.name,
                dni: user.dni,
                active: user.active,
              }));
            } catch (error) {
              throw new Error(`Error al obtener los usuarios`);
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

          await currentAdmin.save(); // Guardar el usuario con la nueva contraseña
          await user.save(); // Guardar el usuario con la nueva contraseña
      
          return true; // Retornar true si se cambió la contraseña exitosamente
        } catch (error) {
          console.error("Error changing password:", error);
          throw new Error("Failed to change password"); // Lanzar un error genérico en caso de fallo
        }
      },

      changePassword: async (_root: any, args: { old: string, new: string }, context: Context): Promise<boolean> => {
        try {
          const currentUser = await me(context);
          
          if (!currentUser) {
            throw new Error("User not found");
          }
      
          // Verificar si la contraseña antigua coincide
          const isPasswordMatch = await comparePassword(currentUser.password, args.old);
          
          if (!isPasswordMatch) {
            throw new Error("Incorrect old password");
          }


          
      
          // Si coincide, actualizar la contraseña
          currentUser.password = await hashPassword(args.new);


          const logMessage = `${new Date().toISOString()} - Mutation operation: ${currentUser.name} change password`;
          currentUser.logs.push(logMessage);
          await writeLog(logMessage);

          await currentUser.save(); // Guardar el usuario con la nueva contraseña
      
          return true; // Retornar true si se cambió la contraseña exitosamente
        } catch (error) {
          console.error("Error changing password:", error);
          throw new Error("Failed to change password"); // Lanzar un error genérico en caso de fallo
        }
      },
      

      // cambiar la status de si mateix o per admin
      changeUserStatus: async (_root: any, args: { dni: string }, context: Context): Promise<boolean> => {

        try {
          // Buscar el usuario por DNI
          const user = await User.findOne({ dni: args.dni });
          if (!user) {
            throw new Error("User does not exist");
          }
      
          // Alternar el estado del usuario
          const newStatus: boolean = !user.active; // Cambia el estado actual y asegura el tipo primitivo booleano
          await User.updateOne(
            { dni: args.dni },
            { $set: { active: newStatus } }
          );
      
          // Verificar si el usuario ha sido actualizado
          const updatedUser = await User.findOne({ dni: args.dni });
      
          // Asegúrate de retornar un valor booleano
          return updatedUser ? updatedUser.active === true : false; // Convierte explícitamente a booleano
        } catch (error) {
          console.error("Error setting user active status:", error);
          throw new Error("Failed to update user status");
        }
      },
      
      

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


      removeUser: async (_root: any, args: any, context: Context) => {
        // No se puede eliminar el rol admin
    
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
  
          // Inicializar logMessage
          let logMessage = '';
        
          try {
            // Verificar si ya existe un usuario con el mismo DNI
            const existingUser = await User.findOne({ dni });
            if (existingUser) {
              // Si el usuario ya existe, registrar el mensaje en los logs del usuario existente
              logMessage = `${new Date().toISOString()} - Operación fallida: Usuario con DNI ${dni} ya existe.`;
              existingUser.logs.push(logMessage);
              await existingUser.save();
              throw new Error("User already exists");
            }
        
            // Crear nuevo usuario
            const userInput = {
              dni: dni,
              name: name,
              active: true,
              password: await hashPassword(password),
            };
        
            const user = new User(userInput);
        
            // Crear una nueva cuenta para el usuario
            const newAccount = new Account({
              owner_dni: dni,
              owner_name: name,
              number_account: generateUniqueAccountNumber(), // Generar un número de cuenta único
              balance: 10.5, // Saldo inicial
              active: true,
              key_to_pay: "1234567890123456",
              maximum_amount_once: 50,
              maximum_amount_day: 500,
              description: "cuenta nomina",
            });
        
            // Guardar la nueva cuenta
            await newAccount.save();
        
            // Añadir la nueva cuenta al array de cuentas del usuario
            user.accounts.push(newAccount._id);

            logMessage = `${new Date().toISOString()} - Operación: Usuario ${dni} registrado y cuenta ${newAccount.number_account} creada.`;
            user.logs.push(logMessage);
        
            // Guardar el usuario con los logs actualizados
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
          // Buscar el usuario por nombre
          const user = await User.findOne({ name }).select("password accounts");
          
          if (!user) {
            throw new Error("Usuario no encontrado");
          }
      
          // Verificar la contraseña del usuario
          const isPasswordValid = await comparePassword(user.password, password);
          if (!isPasswordValid) {
            throw new Error("Usuario o contraseña inválidos");
          }
      
          // Obtener el token de acceso
          const accessToken = getAccessToken(
            {
              user: user.id.toString(),
            },
            {
              expiresIn: "1d",
            }
          );
      
          // Retornar el token de acceso y el usuario
          return {
            access_token: accessToken,
            user: user,
          };
      
        } catch (error) {
          console.error(error); // Loguear el error para depuración
          //throw new Error(`Error al iniciar sesión: ${error.message}`);
        }
      },

    },
};


