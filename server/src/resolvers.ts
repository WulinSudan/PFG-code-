import db from './_db.js';

// Resolvers define how to fetch the types defined in your schema.
// This resolver retrieves books from the "books" array above.

// per connectar amb front-end
export const resolvers = {
    Query: {
      books: () => db.books,
      authors:() => db.authors,
      users:() => db.users,
    },

    Mutation: {
    // Resolver para eliminar un usuario por ID y devolver el número de usuarios restantes
    removeUser: (parent: any, args: { userId: number }) => {
      const { userId } = args;
      const userIndex = db.users.findIndex(user => user.id === userId);
      if (userIndex === -1) {
          throw new Error('Usuario no encontrado');
      }
      // Eliminar el usuario de la matriz
      db.users.splice(userIndex, 1);
      // Devolver el número de usuarios restantes
        return db.users.length;
      },
    },
};