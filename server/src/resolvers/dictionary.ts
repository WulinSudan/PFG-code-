import Dictionary from "../model/dictionary";
import { Types } from "mongoose";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { comparePassword, hashPassword } from "../utils/crypt";
import { User } from "../model/user";
import { Account, IAccount } from "../model/account";
import { print } from "graphql";
import { UUID } from "mongodb";
import { v4 as uuidv4 } from 'uuid';
import crypto from 'crypto';


export const dictionaryResolvers = {
  Query: {
    // Define tus resolvers de Query aquí, si tienes alguno
    getOriginAccount: async (_root: any, args: { qrtext: string }, context: Context): Promise<string> => {
      const { qrtext } = args;

      console.log(qrtext);

      const userId = getUserId(context); // Función que obtiene el ID del usuario desde el contexto
      if (!userId) {
        throw new Error('User not authenticated');
      }

      const dictionary = await Dictionary.findOne({ qrtext, userId: new Types.ObjectId(userId) });
      if (!dictionary) {
        throw new Error('Account not found');
      }
      console.log(dictionary.account);
      return dictionary.account;
    },

    getOperation: async (_root: any, args: { qrtext: string }, context: Context): Promise<string> => {
      const { qrtext } = args;

      console.log(qrtext);

      const userId = getUserId(context); // Función que obtiene el ID del usuario desde el contexto
      if (!userId) {
        throw new Error('User not authenticated');
      }

      const dictionary = await Dictionary.findOne({ qrtext, userId: new Types.ObjectId(userId) });
      if (!dictionary) {
        throw new Error('Account not found');
      }
      console.log("operacio:");
      console.log(dictionary.operation);
      return dictionary.operation;
    },
  },

  Mutation: {

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


    addDictionary: async (_root: any, { input: { encrypt_message, account, operation } }: any) => {

      try {
        // Verificar que encrypt_message no es null o vacío
        if (!encrypt_message) {
          throw new Error("Encrypt message cannot be null or empty");
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
        
        console.log("generat un codi qr");
        return dictionary;
      } catch (error: any) {
        console.error("Error details:", error);
        if (error.code === 11000) {
          throw new Error("Encrypt message already exists");
        }
        throw new Error("An unexpected error occurred: " + error.message);
      }
    },
  },
};
