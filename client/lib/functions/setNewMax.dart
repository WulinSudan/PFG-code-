import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';

Future<String> setNewMax(String accessToken, String accountNumber, double import) async {
  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  final MutationOptions options = MutationOptions(
    document: gql(setMaxPayImportMutation),
    variables: {
      'accountNumber': accountNumber,
      'maxImport': import, // Se usa directamente `double`
    },
  );

  final QueryResult result = await client.mutate(options);

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  return result.data?['setMaxPayImport'] ?? '';
}
