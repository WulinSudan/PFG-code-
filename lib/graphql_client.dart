import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'main.dart'; // Importa MyApp desde donde sea que esté definido.
import 'package:graphql_flutter/graphql_flutter.dart';


GraphQLProvider createGraphQLProvider() {
  final HttpLink httpLink = HttpLink("http://192.168.1.29:4000/");

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );

  return GraphQLProvider(
    client: client,
    child: MyApp(),
  );
}
