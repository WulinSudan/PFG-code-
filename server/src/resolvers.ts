import db from './_db.js';
import fs from 'fs';
import Movie from './model/movies.js';
import Product from './model/products.js';



// Resolvers define how to fetch the types defined in your schema.
// This resolver retrieves books from the "books" array above.


export const resolvers = {
  Query: {
    products: async () => {
      try {
        const products = await Product.find();
        return products;
      } catch (error) {
        console.error('Error al obtener los productos:', error);
        throw error;
      }
    },
  },
};



