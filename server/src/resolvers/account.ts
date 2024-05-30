import { Types } from "mongoose";
import Account from "../model/account";

export const accountResolvers = {
    Query: {
        allAccount: async () => {
            const persons = await Account.find();
            return persons.map((account) => {
                return {
                    owner: account.owner
                };
            });
        },
        countAccount: async () => {
            return await Account.collection.countDocuments();
        }
    },
    Mutation: {
        addAccount: async (_root: any, args: any) => {
            try {
                const account = new Account({ ...args });
                const savedAccount = await account.save();
                return savedAccount;
            } catch (error) {
                console.error("Error adding account:", error);
                throw error;
            }
        },
        removeAccount: async (_root: any, args: any) => {
            const deletionResult = await Account.deleteOne({ number_account: args.number_account });
            return deletionResult.deletedCount;
        },
    }
};
