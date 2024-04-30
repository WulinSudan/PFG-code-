import { UserInputError } from 'apollo-server-express';
import Person from './model/person.js';
import User from './model/user.js';
import jwt from 'jsonwebtoken';
// Resolvers define how to fetch the types defined in your schema.
// This resolver retrieves books from the "books" array above.
const JWT_SECRET = "paraula_secret";
export const resolvers = {
    Person: {
        address: (root) => {
            return {
                street: root.street,
                city: root.city
            };
        }
    },
    Query: {
        personCount: () => Person.collection.countDocuments(),
        allPersons: async (root, args) => {
            return Person.find({});
        },
        findPerson: async (root, args) => {
            const person = await Person.findOne({ name: args.name });
            return person;
        },
    },
    Mutation: {
        login: async (root, args) => {
            const user = await User.findOne({ username: args.username });
            if (!user || args.password !== user.password) {
                throw new UserInputError('wrong credentials');
            }
            const userForToken = {
                username: user.username,
                password: user.password
            };
            return {
                value: jwt.sign(userForToken, JWT_SECRET)
            };
        },
        signUp: (root, args) => {
            const user = new User({ ...args });
            return user.save();
        },
        addPerson: (root, args) => {
            const person = new Person({ ...args });
            return person.save();
        },
        editNumber: async (root, args) => {
            const person = await Person.findOne({ name: args.name });
            person.phone = args.phone;
            return person.save();
        },
        removePerson: async (root, args) => {
            const deletionResult = await Person.deleteOne({ name: args.name });
            return deletionResult.deletedCount;
        }
    }
};
