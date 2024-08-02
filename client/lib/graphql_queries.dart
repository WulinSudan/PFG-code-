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



final String addDictionaryMutation = """
mutation(\$input: DictionaryInput!) {
  addDictionary(input: \$input) {
    encrypt_message
    account
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
  getOrigenAccount(qrtext: \$qrtext)
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

const String setQrUsedMutation = """
mutation(\$qrtext: String!){
  setQrUsed(qrtext: \$qrtext)
}
""";

const String checkEnableMutation = """
query(\$qrtext: String!){
  checkEnable(qrtext: \$qrtext)
}
""";

const String addTransactionMutation = """
mutation(\$input: TransactionInput!) {
    addTransaction(input: \$input) {
       operation
       import
       create_date
   } 
}
""";








