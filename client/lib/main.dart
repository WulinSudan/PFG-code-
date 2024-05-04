import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const allUsersGraphql = """
  query allUsers{
     allUsers {
        name
     }
  }
""";


void main() {
  final HttpLink httpLink = HttpLink("http://192.168.1.29:4000/");

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );

  var app = GraphQLProvider(
    client: client,
    child: MyApp(),
  );

  runApp(app);
}



class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text("hola"),
          ),
          body: Query(
            options: QueryOptions(
              document: gql(allUsersGraphql),
            ),
            builder: (QueryResult result, {fetchMore, refetch}) {

              if(result.hasException){
                print("exception");
                return Text(result.exception.toString());
              }

              if(result.isLoading){
                print("Loading");
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final userList = result.data?["allUsers"];

              print(userList);

              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      itemCount: userList.length,
                      itemBuilder: (_, index){
                        return Text(userList[index]['name']);
                      }, 
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    )
                  )
                ],
              );
            },
          )
        ),
    );
  }
}

