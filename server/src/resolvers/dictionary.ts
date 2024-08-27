import Dictionary from "../model/dictionary";
import { Types, UpdateWriteOpResult } from "mongoose";
import { Context } from "../utils/context";
import { getUserId } from "../utils/jwt";
import { User } from "../model/user";
import { Account, IAccount } from "../model/account";
import crypto from 'crypto';


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

export const dictionaryResolvers = {
  Query: {
    checkEnable: async (_root: any, args: { qrtext: string }, context: Context): Promise<boolean> => {
      // Check if the user is authenticated
      const currentUser = await me(context);
      if (!currentUser) {
        throw new Error("User not authenticated");
      }
    
      const { qrtext } = args;
    
      // Ensure that qrtext is valid and not empty
      if (!qrtext) {
        throw new Error('QR text is required');
      }
    
      try {
        // Search the database for the dictionary entry by qrtext
        const dictionary = await Dictionary.findOne({ encrypt_message: qrtext });
    
        // If the dictionary entry is not found, throw an error
        if (!dictionary) {
          throw new Error('Dictionary entry not found');
        }
    
        // Check the current value of 'enable'
        if (!dictionary.enable) {
          return false; // No further checks are needed if 'enable' is already false
        }
    
        // Verify the creation date
        const createDate: Date = dictionary.create_date;
        if (!createDate) {
          throw new Error('Create date not found in dictionary entry');
        }
    
        // Get the current date
        const now: Date = new Date();
        const expirationTime: Date = new Date(createDate);
        expirationTime.setMinutes(expirationTime.getMinutes() + 2); // Add 2 minutes to the creation date
    
        // Check if more than 2 minutes have passed
        if (now > expirationTime) {
          console.log('In the checkEnable function, more than 2 minutes have passed');
          return false;
        }
    
        return true; // If all checks are correct, return true
      } catch (error) {
        console.error('Error in checkEnable:', (error as Error).message);
        return false; // Handle the error and return false
      }
    },
    getOrigenAccount: async (_root: any, args: { qrtext: string }, context: Context): Promise<string> => {

      const currentUser = await me(context);
      if (!currentUser) {
        throw new Error("User not authenticated");
      }

      const { qrtext } = args;

      // Ensure that qrtext is valid and not empty
      if (!qrtext) {
        throw new Error('QR text is required');
      }

      try {
        // Search the database only by qrtext
        const dictionary = await Dictionary.findOne({ encrypt_message: qrtext });

        // If the dictionary entry is not found, throw an error
        if (!dictionary) {
          throw new Error('Account not found');
        }

        // Log the account type for debugging purposes only
        console.log(`In getOriginAccount, the found account is: ${dictionary.account}`);

        // Return the found account
        return dictionary.account;
      } catch (error) {
        // Handle possible errors during the query
        console.error('Error retrieving the origin account:', error);
        throw new Error('Error retrieving the origin account');
      }
    },
  }, 

  Mutation: {
    setQrUsed: async (_root: any, args: { qrtext: string }, context: Context): Promise<boolean> => {

      const currentUser = await me(context);
      if (!currentUser) {
        throw new Error("User not authenticated");
      }

      const { qrtext } = args;
    
      // Ensure that qrtext is valid and not empty
      if (!qrtext) {
        throw new Error('QR text is required');
      }
    
      try {
        // Search the database by qrtext and update enable to false
        const updateResult: UpdateWriteOpResult = await Dictionary.updateOne(
          { encrypt_message: qrtext },
          { $set: { enable: false } }
        );
    
        console.log(`QR text: ${qrtext}`);
        console.log(`Update result: ${JSON.stringify(updateResult)}`);
    
        // Check if the entry was found and updated
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
    
        console.log("Account successfully disabled.");
        console.log(`Enable status: ${dictionary.enable}`);
    
        // Check if the update was successful and return true if enable was set to false
        return !dictionary.enable;
      } catch (error) {
        console.error('Error updating dictionary entry:', error);
        throw new Error('Error updating dictionary entry');
      }
    },
    setNewKey: async (_root: any, { accountNumber }: { accountNumber: string }, context:Context): Promise<string> => {
      try {
        // Input validation
        const currentUser = await me(context);
        if (!currentUser) {
          throw new Error("User not authenticated");
        }

        if (!accountNumber) {
          throw new Error("Account number is required");
        }
    
        // Find the account
        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }
        console.log(`Current account: ${account.number_account}`);
        console.log(`In the setNewKey function, the old key: ${account.key_to_pay}`);
    
        // Generate a new key
        const newKey = crypto.randomBytes(8).toString('hex').toUpperCase();
        console.log(`In the setNewKey function, generated key: ${newKey}`);
    
        // Update the key_to_pay field and get the updated document
        const updatedAccount = await Account.findOneAndUpdate(
          { number_account: accountNumber },
          { $set: { key_to_pay: newKey } },
        );
    
        return newKey;
      } catch (error) {
        console.error("Error setting new key:", error);
        throw new Error("Failed to set new key");
      }
    },
    addDictionary: async (_root: any, { input: { encrypt_message, account } }: any, context:Context) => {

      try {
        const currentUser = await me(context);
        if (!currentUser) {
          throw new Error("User not authenticated");
        }

        // Ensure that encrypt_message is not null or empty
        if (!encrypt_message) {
          throw new Error("Encrypt message cannot be null or empty");
        }
    
        console.log("In the addDictionary function");
    
        // Get the current date and time
        const now = new Date(); 
    
        const newDictionary = new Dictionary({
          encrypt_message: encrypt_message,
          account: account,
          create_date: now, // Use the current date
        });
    
        await newDictionary.save();
    
        console.log("In the addDictionary function: a QR code has been generated");
        return newDictionary;
      } catch (error: any) {
        console.error("Error details:", error);
        throw new Error("An unexpected error occurred: " + error.message);
      }
    },
  },

};
