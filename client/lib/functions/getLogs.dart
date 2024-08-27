import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<List<String>> getLogs(String accessToken, String dni) async {
  // Create the GraphQL client with the access token
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  // Configure the query options
  final QueryOptions options = QueryOptions(
    document: gql(getLogsQuery), // Query to get the logs
    variables: {'dni': dni}, // Pass the DNI as a variable to the query
  );

  // Execute the query
  final QueryResult result = await client.query(options);

  // Handle exceptions
  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  // Extract data from the result
  final Map<String, dynamic> data = result.data ?? {};

  // Assuming user logs are under `data['getLogs']`
  if (data.containsKey('getLogs')) {
    List<String> logs = List<String>.from(data['getLogs']);

    // Reverse the order of logs
    logs = logs.reversed.toList();

    return logs;
  } else {
    throw Exception("Unable to retrieve user logs.");
  }
}
