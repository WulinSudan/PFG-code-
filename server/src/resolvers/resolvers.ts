import { personResolvers } from "./person";
import { userResolvers } from "./user";

export const resolvers = {
    Query: Object.assign(userResolvers.Query, personResolvers.Query),
    Mutation: Object.assign(userResolvers.Muation, personResolvers.Muation),
};
