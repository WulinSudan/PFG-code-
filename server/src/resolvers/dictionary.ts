import Dictionary from "../model/dictionary";
import { Types, UpdateWriteOpResult } from "mongoose";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { comparePassword, hashPassword } from "../utils/crypt";
import { User } from "../model/user";
import { Account, IAccount } from "../model/account";
import { print } from "graphql";
import { UUID } from "mongodb";
import { v4 as uuidv4 } from 'uuid';
import crypto from 'crypto';
import { BlobOptions } from "buffer";
import { UpdateResult } from 'mongodb'; // Import MongoDB native types



export const dictionaryResolvers = {
  Query: {
    // Define tus resolvers de Query aquí, si tienes alguno
    getOriginAccount: async (_root: any, args: { qrtext: string }, context: Context): Promise<string> => {
      const { qrtext } = args;

      // Asegúrate de que qrtext sea válido y no esté vacío
      if (!qrtext) {
        throw new Error('QR text is required');
      }

      try {
        // Buscar en la base de datos solo por qrtext
        const dictionary = await Dictionary.findOne({ encrypt_message: qrtext });

        // Si no se encuentra el diccionario, lanzar un error
        if (!dictionary) {
          throw new Error('Account not found');
        }

        // Imprimir el tipo de operación solo para fines de depuración
        console.log(`En getOriginAccount, la cuenta encontrada es: ${dictionary.account}`);
        //console.log(${dictionary.qrtext}, ${})

        // Devolver la cuenta encontrada
        return dictionary.account;
      } catch (error) {
        // Manejar posibles errores durante la consulta
        console.error('Error al obtener la cuenta de origen:', error);
        throw new Error('Error al obtener la cuenta de origen');
      }
    },

    getOperation: async (_root: any, args: { qrtext: string }, context: Context): Promise<string> => {
      const { qrtext } = args;
      
      const userId = getUserId(context); // Función que obtiene el ID del usuario desde el contexto
      if (!userId) {
        throw new Error('User not authenticated');
      }

      const dictionary = await Dictionary.findOne({ encrypt_message: qrtext });
      if (!dictionary) {
        throw new Error('Account not found');
      }
      console.log(`En getOperation, el tipo de operacion es: ${dictionary.operation}`);
      return dictionary.operation;
    },
  },

  Mutation: {

    checkEnable: async (_root: any, args: { qrtext: string }, context: Context): Promise<boolean> => {

      console.log("En la funcion checkEnable............");
      const { qrtext } = args;
    
      // Asegúrate de que qrtext sea válido y no esté vacío
      if (!qrtext) {
        throw new Error('QR text is required');
      }
    
      try {
        // Buscar en la base de datos el diccionario por qrtext
        const dictionary = await Dictionary.findOne({ encrypt_message: qrtext });
    
        // Si no se encuentra el diccionario, lanzar un error
        if (!dictionary) {
          throw new Error('Dictionary entry not found');
        }
    
        // Verificar si la operación es 'payment'
        if (dictionary.operation !== 'payment') {
          // Si no es 'payment', simplemente devuelve el valor actual de 'enable'
          return dictionary.enable;
        }
    
        // Verificar el valor actual de 'enable'
        if (!dictionary.enable) {
          return false; // No es necesario hacer más comprobaciones si 'enable' ya es false
        }
    
        // Verificar la fecha de creación
        const createDate = dictionary.create_date;
        if (!createDate) {
          throw new Error('Create date not found in dictionary entry');
        }
    
        // Obtener la fecha actual
        const now = new Date();
        const expirationTime = new Date(createDate);
        expirationTime.setMinutes(expirationTime.getMinutes() + 2); // Agregar 2 minutos a la fecha de creación
    
        // Comprobar si ha pasado más de 2 minutos
        if (now > expirationTime) {
          // Actualizar el campo 'enable' a false
          const updateResult = await Dictionary.updateOne(
            { encrypt_message: qrtext },
            { $set: { enable: false } }
          );
    
          // Verificar si se actualizó algún documento
          if (updateResult.modifiedCount > 0) {
            return false; // Se actualizó, así que el valor de 'enable' es ahora false
          } else {
            throw new Error('Failed to update dictionary entry');
          }
        } else {
          // No se ha pasado el tiempo de expiración
          return dictionary.enable; // Devolver el valor actual de 'enable'
        }
      } catch (error) {
        //console.error('Error en checkEnable:', error.message);
        return false; // Manejar el error y devolver false
      }
    },
    

setQrUsed : async (
  _root: any,
  args: { qrtext: string },
  context: Context
): Promise<boolean> => {
  console.log("En la función setQrUsed...");

  const { qrtext } = args;

  // Asegúrate de que qrtext sea válido y no esté vacío
  if (!qrtext) {
    throw new Error('QR text is required');
  }

  try {
    // Buscar en la base de datos solo por qrtext y actualizar enable a false
    const updateResult: UpdateWriteOpResult = await Dictionary.updateOne(
      { encrypt_message: qrtext },
      { $set: { enable: false } }
    );

    console.log(`QR text: ${qrtext}`);
    console.log(`Update result: ${JSON.stringify(updateResult)}`);

    // Verificar si se encontró y actualizó la entrada
    if (updateResult.matchedCount === 0) {
      console.error('No documents matched the query. Check if the qrtext exists.');
      throw new Error('Dictionary entry not found');
    }

    if (updateResult.modifiedCount === 0) {
      console.log('Dictionary entry was already disabled or not modified');
    }

    const dictionary = await Dictionary.findOne({ encrypt_message: qrtext });

    if (!dictionary) {
      throw new Error('Dictionary entry not found after update');
    }

    console.log("Cuenta deshabilitada exitosamente.");
    console.log(`Estado de habilitación: ${dictionary.enable}`);

    // Verificar si la actualización fue exitosa y devolver true si enable fue actualizado a false
    return !dictionary.enable;
  } catch (error) {
    console.error('Error updating dictionary entry:', error);
    throw new Error('Error updating dictionary entry');
  }
},


    setNewKey: async (_root: any, { accountNumber }: { accountNumber: string }): Promise<string> => {
      try {
        // Validación de entrada
        if (!accountNumber) {
          throw new Error("Account number is required");
        }

        // Buscar la cuenta
        const account = await Account.findOne({ accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }

        // Generar una nueva clave
        //const newKey = uuidv4();
        const newKey = crypto.randomBytes(8).toString('hex').toUpperCase();

        // Actualizar el campo key_to_pay
        await Account.updateOne(
          { accountNumber },
          { $set: { key_to_pay: newKey, qr_pay_create_date: new Date().toISOString() } }
        );

        return newKey;
      } catch (error) {
        console.error("Error setting new key:", error);
        throw new Error("Failed to set new key");
      }
    },


    addDictionary:async (_root: any, { input: { encrypt_message, account, operation } }: any) => {
      try {
        // Verificar que encrypt_message no es null o vacío
        if (!encrypt_message) {
          throw new Error("Encrypt message cannot be null or empty");
        }
    
        // Verificar si encrypt_message ya existe en la base de datos
        const existingEntry = await Dictionary.findOne({ encrypt_message });
        if (existingEntry) {
          console.log("Encrypt message already exists, no action taken");
          return existingEntry;
        }
    
        // Obtener la fecha y hora actuales
        const now = new Date(); 
    
        const dictionaryInput = {
          encrypt_message,
          account,
          operation,
          create_date: now, // Usar la fecha actual
        };
    
        const dictionary = new Dictionary(dictionaryInput);
        await dictionary.save();
    
        console.log("En la función addDictionary: generado un código QR");
        return dictionary;
      } catch (error: any) {
        console.error("Error details:", error);
        throw new Error("An unexpected error occurred: " + error.message);
      }
    },
  },
};
