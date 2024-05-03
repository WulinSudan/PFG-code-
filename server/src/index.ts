import { ApolloServer } from "@apollo/server";
import { startStandaloneServer } from "@apollo/server/standalone";
import { resolvers } from "./resolvers/resolvers";
import fs from "fs";
import { buildSchema, GraphQLSchema } from "graphql";
import mongoose from "mongoose";
import { Context, createContext } from "./utils/context";

//connecxió a base de dades
mongoose.set("strictQuery", true);

//mongoose.connect('mongodb+srv://sudan88792:sudan6519@pfgcluster.fe95ztn.mongodb.net/PFG?retryWrites=true&w=majority');
mongoose.connect(
    "mongodb+srv://sudan88792:sudan6519@pfgcluster.fe95ztn.mongodb.net/pfg?retryWrites=true&w=majority&appName=PFGCluster"
);
const db = mongoose.connection.once("open", () => {
    console.log("Conectado a la base de datos pfg");
});

const schemaString: string = fs.readFileSync(
    "src/graphql/schema.graphql",
    "utf-8"
);

const schema: GraphQLSchema = buildSchema(schemaString);

const server = new ApolloServer<Context>({
    typeDefs: schema,
    resolvers,
});

startStandaloneServer(server, {
    listen: { port: 4000 },
    context: createContext,
})
    .then(({ url }) => {
        console.log(`🚀  Server ready at: ${url}`);
    })
    .catch((error) => {
        console.log(error);
    });
