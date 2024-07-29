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
      maximum_amount_once
    }
  }
""";

final String addAccountMutation = """
  mutation {
    addAccountByAccessToken {
      balance
    }
  }
""";


const String removeAccountMutation = """
  mutation m(\$number_account: String!) {
    removeAccount(number_account: \$number_account)
  }
 """;


final String makeTransferMutation = """
mutation MakeTransfer(\$input: TransferInput!) {
  makeTransfer(input: \$input) {
    success
    message
  }
}
""";


final String getPayKeyQuery = """
query(\$accountNumber: String!){
  getAccountPayKey(accountNumber: \$accountNumber)
}
""";


final String getChargeKeyQuery = """
query(\$accountNumber: String!){
  getAccountChargeKey(accountNumber: \$accountNumber)
}
""";


final String addKeyToDictionaryMutation = """
mutation(\$input: DictionaryInput!) {
  addDictionary(input: \$input) {
    encrypt_message
    account
    operation
    create_date
  }
}
""";


final String setNewKeyMutation = """
mutation setNewKey(\$accountNumber: String!) {
  setNewKey(accountNumber: \$accountNumber)
}
""";


const String getOrigenAccountQuery = """
query(\$qrtext: String!) {
  getOriginAccount(qrtext: \$qrtext)
}
""";



final String getOperationQuery = """
query(\$qrtext: String!){
  getOperation(qrtext: \$qrtext)
}
""";


const String addAccountByUserMutation =""""
mutation AddAccount(\$input: addAccountInput!) {
  addAccountByUser(input: \$input) {
    owner_name
    balance
  }
}
""";


const String setMaxPayImportMutation = """
mutation(\$accountNumber: String!, \$maxImport: Float!){
  setMaxPayImport(accountNumber: \$accountNumber, maxImport: \$maxImport)
}
""";









