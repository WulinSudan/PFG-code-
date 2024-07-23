import { personResolvers } from "./person";
import { userResolvers } from "./user";
import { accountResolvers } from "./account";
import { dictionaryResolvers } from "./dictionary";

export const resolvers = {
    Query: Object.assign(userResolvers.Query, 
                         personResolvers.Query,
                         accountResolvers.Query,
                        dictionaryResolvers.Query,),
    Mutation: Object.assign(userResolvers.Mutation, 
                            personResolvers.Mutation,
                            accountResolvers.Mutation,
                            dictionaryResolvers.Mutation),
};
