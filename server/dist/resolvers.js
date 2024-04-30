import Person from './model/person.js';
// Resolvers define how to fetch the types defined in your schema.
// This resolver retrieves books from the "books" array above.
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
