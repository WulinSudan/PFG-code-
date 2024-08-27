import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../utils/user.dart'; // Ensure the User class is imported

Future<List<User>> getUsers(String accessToken) async {
  print("In the getUsers function");

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final QueryOptions options = QueryOptions(
    document: gql(getUsersQuery),
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    print("Query error: ${result.exception.toString()}");
    throw Exception(result.exception.toString());
  }

  // Print the query result for debugging
  print("Query result: ${result.data}");

  // Change 'getUsers' to the correct key based on your result
  final List<dynamic>? usersJson = result.data?['getUsers'];

  if (usersJson == null) {
    print('No user data received');
    throw Exception('No user data received');
  }

  // Print the JSON data to verify its content
  print("User JSON data: $usersJson");

  // Convert the JSON data to a list of User objects
  final List<User> users = usersJson.map((json) => User.fromJson(json)).toList();

  // Print the list of users to verify the conversion was correct
  print("Converted users: $users");

  return users;
}
