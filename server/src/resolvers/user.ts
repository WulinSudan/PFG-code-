import { Types } from "mongoose";
import User from "../model/user";
import { Context } from "../utils/context";
import { getAccessToken, getUserId } from "../utils/jwt";
import { comparePassword, hashPassword } from "../utils/crypt";

export const userResolvers = {
    Query: {
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
    Muation: {

        removeUser: async (_root: any, args: any) => {
            const deletionResult = await User.deleteOne({ name: args.name });
            return deletionResult.deletedCount;
        },

        signUp: async (_root: any, { input: {name, password} }: any ) => {
            try {
                const userInput = {
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
        signup: async (_root: any, args: any) => {
            try {
                const userInput = {
                    name: args.name,
                    password: await hashPassword(args.password),
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
    },
};
