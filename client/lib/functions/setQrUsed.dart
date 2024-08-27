import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

// Ensure the function is exported correctly
Future<bool> setQrUsed(String accessToken, String qrText) async {

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(setQrUsedMutation),
        variables: <String, dynamic>{
          'qrtext': qrText,
        },
      ),
    );

    if (result.hasException) {
      print('Error executing mutation: ${result.exception.toString()}');
      return false;
    } else {
      print('Mutation successful');
      // Check if result.data is not null before accessing it
      return result.data != null && result.data!['setQrUsed'] == true;
    }
  } catch (e) {
    print('Unexpected error: $e');
    return false;
  }
}
