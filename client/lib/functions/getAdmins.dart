import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../utils/user.dart'; // Make sure to import the User class

Future<List<User>> getAdmins(String accessToken) async {
  print("Inside the getAdmins function");

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final QueryOptions options = QueryOptions(
    document: gql(getAdminsQuery),
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    print("Error in query: ${result.exception.toString()}");
    throw Exception(result.exception.toString());
  }

  // Print the query result for debugging
  print("Query result: ${result.data}");

  // Change 'getUsers' to the correct key based on your result
  final List<dynamic>? usersJson = result.data?['getAdmins'];

  if (usersJson == null) {
    print('No administrator data received');
    throw Exception('No administrator data received');
  }

  // Print JSON data to verify its content
  print("Administrator JSON data: $usersJson");

  // Convert JSON data to a list of User objects
  final List<User> users = usersJson.map((json) => User.fromJson(json)).toList();

  // Print the list of users to verify that the conversion was correct
  print("Converted administrators: $users");

  return users;
}
