import { personResolvers } from "./person";
import { userResolvers } from "./user";
import { accountResolvers } from "./account";

export const resolvers = {
    Query: Object.assign(userResolvers.Query, 
                         personResolvers.Query,
                         accountResolvers.Query),
    Mutation: Object.assign(userResolvers.Mutation, 
                            personResolvers.Mutation,
                            accountResolvers.Mutation),
};
