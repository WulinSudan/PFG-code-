import { ApolloServer } from '@apollo/server';
import { startStandaloneServer } from '@apollo/server/standalone';
import { resolvers } from './resolvers.js'
import mysql from 'mysql';
import fs from 'fs';
import { buildSchema, GraphQLSchema } from 'graphql';


// Lee el esquema GraphQL desde el archivo
const schemaString: string = fs.readFileSync('src/graphql/schema.graphql', 'utf-8');
// Construye el esquema GraphQL
const schema: GraphQLSchema = buildSchema(schemaString);


// The ApolloServer constructor requires two parameters: your schema
// definition and your set of resolvers.
const server = new ApolloServer({
    typeDefs:schema,
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