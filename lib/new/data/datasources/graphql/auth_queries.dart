// lib/data/datasources/graphql/auth_queries.dart
class AuthQueries {
  AuthQueries._();

  /// Login mutation - using string interpolation (no variables)
  static String loginMutation(String email, String password) =>
      '''
    mutation {
      signin(input: { email: "$email", password: "$password" }) {
        uniqueId
        firstName
        lastName
        imei
        email
        mobile
        userType
        tokens {
          accessToken
          refreshToken
        }
        lastLoginAt
        message
      }
    }
  ''';

  /// Signup mutation - using string interpolation (no variables)
  static String signupMutation(Map<String, dynamic> input) =>
      '''
    mutation {
      signup(input: { 
        firstName: "${input['firstName']}", 
        lastName: "${input['lastName']}", 
        email: "${input['email']}", 
        password: "${input['password']}",
        mobile: "${input['mobile']}"
      }) {
        status
        data {
          user { _id name email }
        }
      }
    }
  ''';

  /// Device IMEI query
  static const String deviceImeiQuery = '''
    query {
      devices {
        imei
      }
    }
  ''';
}
