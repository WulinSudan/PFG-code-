import { print } from 'graphql';
import db from './_db.js';
import fs from 'fs';

// Resolvers define how to fetch the types defined in your schema.
// This resolver retrieves books from the "books" array above.

interface Context {
  // Puedes definir propiedades específicas del contexto aquí si es necesario
}



export const resolvers = {
  Query: {
      books: () => db.books,
      authors: () => db.authors,
      users: () => db.users,
      games: () => db.games,
      reviews: () => db.reviews,
      review(_, args) {
        return db.reviews.find((review) => review.id === args.id);
      },
  },

  Mutation: {

    updateGame(_, args) {
      // Map over the games array in the database
      db.games = db.games.map((g) => {
        // Check if the current game's id matches the id provided in args
        if (g.id === args.id) {
          // If there's a match, update the game with the edits provided in args
          return { ...g, ...args.edits };
        }
        // For non-matching games, return them unchanged
        return g;
      });
    
      // Find and return the updated game from the database
      return db.games.find((g) => g.id === args.id);
    },
    

    addGame(_, args) {
      let game = {
        ...args.game,
        id: Math.floor(Math.random() * 10000).toString()
      };      
      db.games.push(game)

      return game
    },

    deleteGame(_, args) {
      db.games = db.games.filter((g) => g.id !== args.id)
      return db.games
    },


    addBook: (_, { title, author }) => {

      const newBook = {
        title: title,
        author: author,
      };

      db.books.push(newBook);

      console.log("hola");


      return newBook;
    }
  }
};
