"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const server_1 = require("@apollo/server");
const standalone_1 = require("@apollo/server/standalone");
const resolvers_1 = require("./resolvers/resolvers");
const fs_1 = __importDefault(require("fs"));
const graphql_1 = require("graphql");
const mongoose_1 = __importDefault(require("mongoose"));
const context_1 = require("./utils/context");
//connecxió a base de dades
mongoose_1.default.set("strictQuery", true);
//mongoose.connect('mongodb+srv://sudan88792:sudan6519@pfgcluster.fe95ztn.mongodb.net/PFG?retryWrites=true&w=majority');
mongoose_1.default.connect("mongodb+srv://sudan88792:sudan6519@pfgcluster.fe95ztn.mongodb.net/pfg?retryWrites=true&w=majority&appName=PFGCluster");
const db = mongoose_1.default.connection.once("open", () => {
    console.log("Conectado a la base de datos pfg");
});
const schemaString = fs_1.default.readFileSync("src/graphql/schema.graphql", "utf-8");
const schema = (0, graphql_1.buildSchema)(schemaString);
const server = new server_1.ApolloServer({
    typeDefs: schema,
    resolvers: resolvers_1.resolvers,
});
(0, standalone_1.startStandaloneServer)(server, {
    listen: { port: 4000 },
    context: context_1.createContext,
})
    .then(({ url }) => {
    console.log(`🚀  Server ready at: ${url}`);
})
    .catch((error) => {
    console.log(error);
});
