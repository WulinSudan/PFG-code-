import { Types } from "mongoose";
import Person from "../model/person";

export const personResolvers = {
    Query: {
        personCount: async () => {
            return await Person.collection.countDocuments();
        },
        allPersons: async () => {
            const persons = await Person.find();
            return persons.map((person) => {
                return {
                    name: person.name,
                    phone: person.phone,
                    address: {
                        street: person.street,
                        city: person.city,
                    },
                };
            });
        },
        findPerson: async (_root: any, args: any) => {
            const person = await Person.findOne({
                name: args.name,
            });

            return !person
                ? null
                : {
                      name: person.name,
                      phone: person.phone,
                      address: {
                          street: person.street,
                          city: person.city,
                      },
                  };
        },
    },
    Mutation: {
        addPerson: (_root: any, args: any) => {
            const person = new Person({ ...args });
            return person.save();
        },

        editNumber: async (_root: any, args: any) => {
            const person = await Person.findOne({ name: args.name });
            if (!person) {
                throw new Error("Person not found");
            }
            person.phone = args.phone;
            return await person.save();
        },
        removePerson: async (_root: any, args: any) => {
            const deletionResult = await Person.deleteOne({ name: args.name });
            return deletionResult.deletedCount;
        },
    },
};
