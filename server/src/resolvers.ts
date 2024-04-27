import db from './_db.js';
import fs from 'fs';
import Movie from './model/movies.js';
import Product from './model/products.js';
import { v1 as uuid } from 'uuid'
import Person from './model/person.js'
import User from './model/user.js'
import jwt from 'jsonwebtoken'
import { create } from 'domain';
import { UserInputError } from 'apollo-server-express';

// Resolvers define how to fetch the types defined in your schema.
// This resolver retrieves books from the "books" array above.

const JWT_SECRET = "PARABLA_SECRETA";

export const resolvers = {


  Person: {
    address: (root) => {
      return {
        street: root.street,
        city: root.city
      }
    }
  },

  Query: {
    me: (root, args, context) => {
      return context;
    },
    personCount: () => Person.collection.countDocuments(),
    allPersons: async(root, args) => {
      return Person.find({})
    },
    findPerson: async(root, args) => {
      const person = await Person.findOne({ name:args.name })
      return person
    },
  },
  Mutation: {
    createUser: (root, args) =>{
      const user = new User({ username: args.username});
      return user.save();
    },

    login: async (root,args) => {
      const user = await User.findOne({ username: args.username})
      if(!user || args.password !== 'midupassword'){
        throw new UserInputError('wrong credential')
      }
      const userForToken = {
        username: user.username,
      }

      return{
        value:jwt.sign(userForToken, JWT_SECRET)
      }
    },

    addPerson: (root, args) => {
      const person = new Person({ ...args})
      return person.save()
    },

    editNumber: async(root, args) => {
      const person = await Person.findOne({ name:args.name })
      person.phone = args.phone
      return person.save()
    },
    removePerson: async(root, args) => {
      const deletionResult = await Person.deleteOne({ name:args.name})
      return deletionResult.deletedCount
    }
  }
  
};



