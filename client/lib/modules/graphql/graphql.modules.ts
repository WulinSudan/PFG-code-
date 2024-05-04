import { NgModule } from "@angular/core";
import { ApolloModule, Apollo } from "apollo-angular";
import { InMemoryCache } from "@apollo/client/core";
import { HttpLink } from "apollo-angular/http";
import { setContext } from "@apollo/client/link/context";
import { Store } from "@ngxs/store";
import { AuthState } from "src/app/state/auth/auth.state";

const uri = "http://localhost:4000/graphql";

@NgModule({
exports: [ApolloModule],
})
export class GraphQLModule {
constructor(
private apollo: Apollo,
private httpLink: HttpLink,
private store: Store
) {
const authLink = setContext((_, { headers }) => {
const token = this.store.selectSnapshot(AuthState.token);
return {
headers: {
...headers,
Authorization: token ? `Bearer ${token}` : "",
},
};
});

const link = authLink.concat(httpLink.create({ uri: uri }));

const cache = new InMemoryCache({
addTypename: false
});

this.apollo.create({
link,
cache,
})
}
}
