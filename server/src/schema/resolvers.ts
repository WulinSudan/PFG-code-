import { books } from "./typeDefs.js";
// Resolvers define how to fetch the types defined in your schema.
// This resolver retrieves books from the "books" array above.
export const resolvers = {
    Query: {
      books: () => books,
    },
  };