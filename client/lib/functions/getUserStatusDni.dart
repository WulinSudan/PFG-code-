import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<bool> getUserStatusDni(String accessToken, String dni) async {
  // Create the GraphQL client with the access token
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  // Configure the query options with the `dni` parameter
  final QueryOptions options = QueryOptions(
    document: gql(getUserStatusDniQuery), // Query imported from graphql_queries.dart
    variables: <String, dynamic>{
      'dni': dni, // Pass the DNI as a variable to the query
    },
  );

  // Perform the query
  final QueryResult result = await client.query(options);

  // Handle exceptions
  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  // Extract data from the result
  final Map<String, dynamic>? data = result.data;

  // Check if the data contains the user status
  if (data != null && data.containsKey('getUserStatusDni')) {
    final userStatus = data['getUserStatusDni'];
    if (userStatus is Map<String, dynamic> && userStatus.containsKey('active')) {
      return userStatus['active'] as bool;
    } else {
      throw Exception("Could not obtain the user status.");
    }
  } else {
    throw Exception("Could not obtain the user status.");
  }
}
