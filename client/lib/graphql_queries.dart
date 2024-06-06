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
      dni
    }
  }
""";


const String signUpMutation = """
  mutation signUp(\$input: SignUpInput!){
    signUp(input: \$input) {
      dni
    }
  }          
""";

const String getAccountsQuery = """
  query q(\$dni: String!){
    getUserAccountsInfoByDni(dni: \$dni) {
      owner_dni
      owner_name
      number_account
      balance
      active
    }
  }
""";

