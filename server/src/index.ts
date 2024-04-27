import { ApolloServer } from '@apollo/server';
import { gql } from 'apollo-server-express';
import { startStandaloneServer } from '@apollo/server/standalone';
import { resolvers } from './resolvers.js'
import fs from 'fs';
import { buildSchema, GraphQLSchema } from 'graphql';
import mongoose from 'mongoose';
import jwt from 'jsonwebtoken'
import { Request, Response } from 'express';
import User from './model/user.js'


const JWT_SECRET = "PARABLA_SECRETA";

//connecxió a base de dades
mongoose.set('strictQuery', true);

//mongoose.connect('mongodb+srv://sudan88792:sudan6519@pfgcluster.fe95ztn.mongodb.net/PFG?retryWrites=true&w=majority');
mongoose.connect('mongodb+srv://sudan88792:sudan6519@pfgcluster.fe95ztn.mongodb.net/pfg?retryWrites=true&w=majority&appName=PFGCluster');
const db = mongoose.connection.once('open', () => {
    console.log('Conectado a la base de datos pfg');
});


const getone =async ()=>{
  const post = await db.collection("product").findOne({});
}

//getone();



// Lee el esquema GraphQL desde el archivo
const schemaString: string = fs.readFileSync('src/graphql/schema.graphql', 'utf-8');
// Construye el esquema GraphQL
const schema: GraphQLSchema = buildSchema(schemaString);

interface MyContext {
  token?: String;
}

// The ApolloServer constructor requires two parameters: your schema
// definition and your set of resolvers.
const server = new ApolloServer<MyContext>({
    typeDefs: schema,
    resolvers,
    
  });
  
  // Passing an ApolloServer instance to the `startStandaloneServer` function:
  //  1. creates an Express app
  //  2. installs your ApolloServer instance as middleware
  //  3. prepares your app to handle incoming requests
  const { url } = await startStandaloneServer(server, {
    context: async ({ req }) => ({ token: req.headers.token }),
    listen: { port: 4000 },
  });
  
  console.log(`🚀  Server ready at: ${url}`);