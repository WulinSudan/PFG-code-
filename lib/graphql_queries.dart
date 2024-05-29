const String allUsersGraphql = """
  query allUsers {
    allUsers {
      name
    }
  }
""";


const String loginUserMutation = """
  mutation LoginUser(\$input: LoginInput!) {
    loginUser(input: \$input) {
      access_token
    }
  }
""";

const String meQuery = """
  query{
    me{
      name
    }
  }
""";


