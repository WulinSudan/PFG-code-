import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<String> getUserRole(String accessToken, String name) async {
  print("In the getUserRole function");

  // Create the GraphQL client with the access token
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  // Configure the query options
  final QueryOptions options = QueryOptions(
    document: gql(getUserRoleQuery), // Query imported from graphql_queries.dart
    variables: {'name': name}, // Pass the name as a variable to the query
  );

  // Execute the query
  final QueryResult result = await client.query(options);

  // Handle exceptions
  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  // Extract data from the result
  final Map<String, dynamic> data = result.data ?? {};

  // Assuming the user role is in `data['getUserRole']`
  if (data.containsKey('getUserRole')) {
    return data['getUserRole'] as String;
  } else {
    throw Exception("Unable to retrieve the user's role.");
  }
}
