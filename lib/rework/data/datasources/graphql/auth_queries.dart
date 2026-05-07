class AuthQueries {
  AuthQueries._();

  static String loginMutation(String email, String password) =>
      '''
mutation {
  signin(input: {
    email: "$email",
    password: "$password"
  }) {
    uniqueId
    firstName
    lastName
    imei
    userType
    email
    mobile
    tokens {
      accessToken
      refreshToken
    }
    lastLoginAt
    message
  }
}
''';
}
