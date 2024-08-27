import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<String> getUserName(String accessToken) async {
  // Create the GraphQL client with the access token
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  // Configure the query options
  final QueryOptions options = QueryOptions(
    document: gql(getUserNameQuery), // Query imported from graphql_queries.dart
  );

  // Execute the query
  final QueryResult result = await client.query(options);

  // Handle exceptions
  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  // Extract data from the result
  final Map<String, dynamic>? data = result.data;

  // Check if the data contains the user's name
  if (data != null && data.containsKey('getUserName')) {
    return data['getUserName'] as String;
  } else {
    throw Exception("Unable to retrieve the user's name.");
  }
}
