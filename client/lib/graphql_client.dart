import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static GraphQLClient createGraphQLClient(String accessToken) {
    //final HttpLink httpLink = HttpLink("http://192.168.1.57:4000/graphql");
    final HttpLink httpLink = HttpLink("http://10.133.32.60:4000/graphql");
    //final HttpLink httpLink = HttpLink("http://192.168.50.184:4000/graphql");
    final AuthLink authLink = AuthLink(getToken: () async => 'Bearer $accessToken');
    final Link link = authLink.concat(httpLink);
    return GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }
}
