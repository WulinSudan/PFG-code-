import { ApolloServer } from '@apollo/server';
import { startStandaloneServer } from '@apollo/server/standalone';
import { resolvers } from './resolvers.js';
import fs from 'fs';
import { buildSchema } from 'graphql';
import mongoose from 'mongoose';
//connecxió a base de dades
mongoose.set('strictQuery', true);
//mongoose.connect('mongodb+srv://sudan88792:sudan6519@pfgcluster.fe95ztn.mongodb.net/PFG?retryWrites=true&w=majority');
mongoose.connect('mongodb+srv://sudan88792:sudan6519@pfgcluster.fe95ztn.mongodb.net/pfg?retryWrites=true&w=majority&appName=PFGCluster');
const db = mongoose.connection.once('open', () => {
    console.log('Conectado a la base de datos pfg');
});
const getone = async () => {
    const post = await db.collection("product").findOne({});
    console.log("hhh");
    console.log(post);
};
getone();
// Lee el esquema GraphQL desde el archivo
const schemaString = fs.readFileSync('src/graphql/schema.graphql', 'utf-8');
// Construye el esquema GraphQL
const schema = buildSchema(schemaString);
// The ApolloServer constructor requires two parameters: your schema
// definition and your set of resolvers.
const server = new ApolloServer({
    typeDefs: schema,
    resolvers,
});
// Passing an ApolloServer instance to the `startStandaloneServer` function:
//  1. creates an Express app
//  2. installs your ApolloServer instance as middleware
//  3. prepares your app to handle incoming requests
const { url } = await startStandaloneServer(server, {
    listen: { port: 4000 },
});
console.log(`🚀  Server ready at: ${url}`);
