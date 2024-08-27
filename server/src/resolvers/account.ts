import { Account, IAccount } from "../model/account";
import { Types } from "mongoose";
import { Context } from "../utils/context";
import { getUserId } from "../utils/jwt";
import { User, IUser } from "../model/user";
import { Transaction } from "../model/transaction";
import fs from 'fs-extra';
import path from 'path';

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

  const logFilePath = path.join(__dirname, '../../logs/accounts.txt');

  const writeLog = async (message: string) => {
    try {
      await fs.appendFile(logFilePath, `${message}\n`);
    } catch (err) {
      console.error('Error writing to the log file:', err);
    }
  }
  function generateUniqueAccountNumber(): string {
    const now = new Date();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hour = String(now.getHours()).padStart(2, '0');
    const minute = String(now.getMinutes()).padStart(2, '0');
    const second = String(now.getSeconds()).padStart(2, '0');
    
    const aux = `${month}${day}${hour}${minute}${second}`;
    console.log(aux);
    return aux;
  }
  async function findUser(accountNumber: string): Promise<IUser | null> {
    try {
      // Find the account using the account number
      const account = await Account.findOne({ accountNumber }).exec();
      
      if (!account) {
        console.log('No account found with the provided number.');
        return null;
      }

      // Find the user who has the account in their list of accounts
      const user = await User.findOne({ accounts: account._id }).exec();

      return user;
    } catch (error) {
      console.error('Error finding the user:', error);
      throw new Error('Could not find the user.');
    }
  }
  async function findAccount(accountNumber: string): Promise<IAccount | null> {
    try {
      return await Account.findOne({ number_account: accountNumber });
    } catch (error) {
      console.error('Error finding the account:', error);
      throw error;
    }
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

export const accountResolvers = {
  Query: {

    checkEnableAmount: async (
      _: any,
      { amount, accountNumber }: { amount: number; accountNumber: string }
    ): Promise<boolean> => {
      try {
        // Find the account using the provided account number
        const account = await findAccount(accountNumber);
        
        // Check if the account exists
        if (!account) {
          throw new Error("Account not found");
        }
        
        // Check if the requested amount exceeds the available balance
        if (amount > account.balance) {
          throw new Error("Insufficient balance");
        }
        
        // Check if the requested amount exceeds the maximum allowed per transaction
        if (amount > account.maximum_amount_once) {
          throw new Error("Amount exceeds the maximum limit allowed");
        }
        
        // If all checks pass, return true
        return true;
      } catch (error) {
        console.error(error);
        // In case of an error (like insufficient balance), you can handle it by returning false or throwing an exception
        return false; // Or throw an exception depending on how you want to handle it
      }
    },
    getUserAccounts: async (_root: any, context: Context) => {
      try {
        // Retrieve the authenticated user using the `me` function
        const currentUser = await me(context);
        console.log(`Authenticated user: ${currentUser.name}`);

        const accountIds = currentUser.accounts;

        // Check if the user has associated accounts
        if (!Array.isArray(accountIds) || accountIds.length === 0) {
          return [];
        }

        // Find all accounts associated with the user
        const accounts = await Account.find({ _id: { $in: accountIds } });

        // Filter accounts that have a valid owner name
        const validAccounts = accounts.filter(account => account.owner_name);

        return validAccounts;
      } catch (error) {
        console.error('Error fetching user accounts:', error);
        throw new Error('Could not retrieve user account information.');
      }
    },
    // Get information about the user's accounts by DNI
    getUserAccountsInfoByDni: async (_root: any, { dni }: { dni: string }, context: Context) => {

      const currentUser = await me(context);
      console.log(currentUser.name);

      try {
        const user = await User.findOne({ dni });
        if (!user) {
          throw new Error('User not found');
        }

        console.log(user.name);

        const accountIds = user.accounts;

        if (!Array.isArray(accountIds) || accountIds.length === 0) {
          return [];
        }

        const accounts = await Account.find({ _id: { $in: accountIds } });
        const validAccounts = accounts.filter(account => account.owner_name);

        return validAccounts;
      } catch (error) {
        console.error('Error fetching user accounts info by DNI:', error);
        throw new Error('Error fetching user accounts info by DNI');
      }
    },
    // Get the status of an account by its number
    getAccountStatus: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context) => {

      const currentUser = await me(context);

      try {
        const account = await findAccount(accountNumber);

        const logMessage = `${new Date().toISOString()} - Operation query: get account ${accountNumber} status`;
        currentUser.logs.push(logMessage);
        currentUser.save();

        return account?.active || false; 
      } catch (error) {
        console.error('Error retrieving the account status:', error);
        throw new Error('Could not retrieve the account status.');
      }
    },
    // Get the balance of an account by its number
    getAccountBalance: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context) => {
      const currentUser = await me(context);

      try {
        const account = await findAccount(accountNumber);

        const logMessage = `${new Date().toISOString()} - Operation query: get account ${accountNumber} balance`;
        currentUser.logs.push(logMessage);
        currentUser.save();

        return account?.balance || false; 
      } catch (error) {
        console.error('Error retrieving the account balance:', error);
        throw new Error('Could not retrieve the account balance.');
      }
    },
    // Not use
    getMaxPayDay: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context) => {
      const currentUser = await me(context);

      try {
        const account = await findAccount(accountNumber);

        const logMessage = `${new Date().toISOString()} - Operation query: get account ${accountNumber} max pay day`;
        currentUser.logs.push(logMessage);
        currentUser.save();

        return account?.maximum_amount_day || false; 
      } catch (error) {
        console.error('Error retrieving the account status:', error);
        throw new Error('Could not retrieve the account status.');
      }
    },
    // Get the transactions associated with an account
    getAccountTransactions: async (_root: any, { n_account }: { n_account: string }, context: Context) => {

      const currentUser = await me(context);

      try {
        const account = await Account.findOne({ number_account: n_account });
        if (!account) {
          throw new Error('Account not found');
        }

        const transactionIds = account.transactions;
        const transactions = await Transaction.find({ _id: { $in: transactionIds } });
        const validTransactions = transactions.filter(transaction => 
          transaction.operation !== null && 
          transaction.create_date !== undefined && 
          transaction.import !== undefined
        );

        return validTransactions;
      } catch (error) {
        console.error('Error fetching transactions info by account number:', error);
        throw new Error('Error fetching transactions info by account number');
      }
    },
    // Get the payment key of an account
    getAccountPayKey: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context): Promise<string> => {
      try {
        // Get the authenticated user
        const currentUser = await me(context);

        // Find the account with the provided account number and verify that it belongs to the current user
        const account = await Account.findOne({
          number_account: accountNumber,
          userId: new Types.ObjectId(currentUser._id)
        });

        if (!account) {
          throw new Error('Account not found');
        }

        // Log the operation in the user's logs
        const logMessage = `${new Date().toISOString()} - Operation query: get account ${accountNumber} key`;
        currentUser.logs.push(logMessage);

        // Save the changes to the user's logs
        await currentUser.save();

        // Return the account payment key
        return account.key_to_pay;
      } catch (error) {
        console.error('Error fetching the payment key of the account:', error);
        throw new Error('Could not retrieve the payment key of the account.');
      }
    },
    // Find an account by its number
    findAccount: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context) => {
      try {
        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          return null;
        }

        return {
          number_account: account.number_account,
          owner_dni: account.owner_dni,
          owner_name: account.owner_name,
          balance: account.balance,
          active: account.active,
          maximum_amount_day: account.maximum_amount_day,
          maximum_amount_once: account.maximum_amount_once,
        };
      } catch (error) {
        console.error('Error finding the account:', error);
        throw error;
      }
    },
    // Not use
    getAllAccounts: async (): Promise<IAccount[]> => {
      try {
        return await Account.find();
      } catch (error) {
        console.error('Error fetching accounts:', error);
        throw new Error('Error fetching accounts');
      }
    },
    // Not use
    countAccount: async () => {
      return await Account.countDocuments();
    },
  },

  Mutation: {
    // Set the description for an account
    setAccountDescription: async (_root: any, { accountNumber, description }: { accountNumber: string, description: string }, context: Context): Promise<string> => {
      try {
        // Get the authenticated user
        const currentUser = await me(context);

        // Find the account by its number
        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }

        // Update the account with the new description
        await Account.updateOne(
          { number_account: accountNumber },
          { $set: { description } }
        );

        // Log the operation
        const logMessage = `${new Date().toISOString()} - Mutation operation: set account ${accountNumber} description`;
        currentUser.logs.push(logMessage);
        await currentUser.save();

        return description;
      } catch (error) {
        console.error("Error setting new description:", error);
        throw new Error("Failed to set account description");
      }
    },
    // Change the status of an account
    changeAccountStatus: async (_root: any, { accountNumber }: { accountNumber: string }, context: Context): Promise<boolean> => {
      console.log("In changeAccountStatus");

      try {
        // Get the current user
        const currentUser = await me(context);

        // Find the account by its number
        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }

        // Toggle the account status
        const newStatus = !account.active; // Toggle the current status
        await Account.updateOne(
          { number_account: accountNumber },
          { $set: { active: newStatus } }
        );

        // Verify if the account has been updated
        const updatedAccount = await Account.findOne({ number_account: accountNumber });
        if (!updatedAccount) {
          throw new Error("Failed to retrieve updated account status");
        }

        // Log the operation in the current user's logs
        const logMessage = `${new Date().toISOString()} - Mutation operation: changed account ${accountNumber} status to ${newStatus} by ${currentUser.name}`;
        currentUser.logs.push(logMessage);
        await currentUser.save();

        await writeLog(logMessage);

        // Return the updated status
        return updatedAccount.active;
      } catch (error) {
        console.error("Error setting account active status:", error);
        throw new Error("Failed to update account status");
      }
    },
    setMaxPayImport: async (_root: any, { accountNumber, maxImport }: { accountNumber: string, maxImport: number }, context:Context): Promise<number> => {
      try {
        const currentUser = await me(context);
        const account = await Account.findOne({ number_account: accountNumber });
        if (!account) {
          throw new Error("Account does not exist");
        }

        await Account.updateOne(
          { number_account: accountNumber },
          { $set: { maximum_amount_once: maxImport } }
        );

        const logMessage = `${new Date().toISOString()} - Mutation operation: set accounts max pay import in ${maxImport}`;
        currentUser.logs.push(logMessage);
        await currentUser.save();

        return maxImport;
      } catch (error) {
        console.error("Error setting new maxPayImport:", error);
        throw new Error("Failed to set max pay import");
      }
    },
    addAccountByUser: async (_root: any, { input: { owner_dni, owner_name } }: AddAccountArgs): Promise<IAccount> => {
      try {
        const newAccount = new Account({
          owner_dni,
          owner_name,
          number_account: generateUniqueAccountNumber(),
          balance: 10.5,
          active: true,
          key_to_pay: "1234567890123456",
          maximum_amount_once: 50,
          maximum_amount_day: 500,
          description: "cuenta nomina",
        });

        await newAccount.save();

        const user = await User.findOne({ dni: owner_dni });
        if (!user) {
          throw new Error('User not found');
        }

        user.accounts.push(newAccount._id);
        await user.save();

        return newAccount;
      } catch (error) {
        throw new Error('Error creating account');
      }
    },
    // Agregar una cuenta al usuario autenticado
    addAccountByAccessToken: async (_root: any, _args: any, context: Context): Promise<IAccount> => {
      try {
        const currentUser = await me(context);

        const newAccount = new Account({
          owner_dni: currentUser.dni,
          owner_name: currentUser.name,
          number_account: generateUniqueAccountNumber(),
          balance: 10.5,
          active: true,
          key_to_pay: "1234567890123456",
          maximum_amount_once: 50,
          maximum_amount_day: 500,
          description: "cuenta nomina",
        });

        await newAccount.save();

        currentUser.accounts.push(newAccount._id);

        const logMessage = `${new Date().toISOString()} - Mutation operation: add accounts`;
        currentUser.logs.push(logMessage);
        
        await currentUser.save();

        return newAccount;
      } catch (error) {
        throw new Error('Error creating account for the user');
      }
    },
    // falta utilizar me
    removeAccount: async (_root: any, { number_account }: { number_account: string }, context: Context) => {
      
      const currentUser = await me(context);
      if(!currentUser){
        throw("User not find");
      }

      const account = await findAccount(number_account);
      if (!account) {
        throw new Error('Account not found');
      }

      if (account.balance > 0) {
        throw new Error('Cannot delete the account because the balance is greater than 0.');
      }

      const deletionResult = await Account.deleteOne({ _id: account._id });

      const logMessage = `${new Date().toISOString()} - Mutation operation: remove user accounts ${number_account}`;
      currentUser.logs.push(logMessage);
    
      if (deletionResult.deletedCount === 0) {
        throw new Error('Failed to delete the account.');
      }

      currentUser.accounts = currentUser.accounts.filter(accountId => !accountId.equals(account._id));
      await currentUser.save();

      console.log('Account deleted successfully');
      return deletionResult.deletedCount;
    },
    // Perform a transfer between accounts
    // Pending implementation
    makeTransfer: async (_root: any, { input }: { input: TransferInput }, context: Context): Promise<any> => {


      const userOrigen = await findUser(input.accountOrigen);
      console.log(userOrigen?.name);

      const userDestin = await findUser(input.accountDestin);

      const currentUser = await me(context);
      if(!currentUser){
        throw("Not User provided")
      }


      if(currentUser.dni === userOrigen!.dni){
        if(userOrigen!.active == false){
          throw("Current User desenable")
        }
      }

      // To determine which account is the source
      // From a bank account, find the user

      try {
        const accountOrigenDoc = await findAccount(input.accountOrigen);
        const accountDestinDoc = await findAccount(input.accountDestin);

        if(accountOrigenDoc!.active == false){
          throw("Current Account desenable")
        }

        if (!accountOrigenDoc || !accountDestinDoc) {
          return {
            success: false,
            message: 'One or both accounts do not exist.',
          };
        }

        if (accountOrigenDoc._id.equals(accountDestinDoc._id)) {
          return {
            success: false,
            message: 'Cannot transfer to the same account.',
          };
        }

        const importNumber = Number(input.import);

        if (isNaN(importNumber) || importNumber <= 0) {
          return {
            success: false,
            message: 'The amount to transfer must be a valid number greater than zero.',
          };
        }

        if (accountOrigenDoc.balance < importNumber) {
          return {
            success: false,
            message: 'Insufficient balance in the source account.',
          };
        }

        if (importNumber > accountOrigenDoc.maximum_amount_once) {
          return {
            success: false,
            message: 'Exceeds the maximum allowed for a single transaction.',
          };
        }

        accountOrigenDoc.balance -= importNumber;
        accountDestinDoc.balance += importNumber;

        await accountOrigenDoc.save();
        await accountDestinDoc.save();

        // Log the operation for the current user
        const logMessage = `${new Date().toISOString()} - Mutation operation: make transfer from ${input.accountOrigen} to ${input.accountDestin} with value ${importNumber}`;
        
        userDestin?.logs.push(logMessage);
        userOrigen?.logs.push(logMessage);

        await writeLog(logMessage);

        return {
          success: true,
          message: `Transfer of ${importNumber} units successfully made from ${input.accountOrigen} of ${userOrigen} to ${input.accountDestin} of ${userDestin}.`,
        };
      } catch (error) {
        console.error('Error performing the transfer:', error);
        return {
          success: false,
          message: 'Error performing the transfer. Please try again later.',
        };
      }
    },
  },
};
