import { Types } from "mongoose";
import Account from "../model/account";

export const accountResolvers = {
    Query: {
        allAccount: async () => {
            try {
                const count = await Account.countDocuments();
                return count;
            } catch (error) {
                console.error("Error fetching account count:", error);
                throw error;
            }
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
        }
    }
};
