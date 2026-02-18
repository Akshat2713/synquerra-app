class AuthQueries {
  // 1. LOGIN: Injected directly into the input object
  static String loginMutation(String email, String password) =>
      '''
    mutation {
      signin(input: { email: "$email", password: "$password" }) {
        uniqueId firstName lastName imei email mobile userType 
        tokens { accessToken refreshToken } 
        lastLoginAt message
      }
    }
  ''';

  // 2. SIGNUP: Passing a dynamic Map for flexible input
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

  // 3. DEVICES: Simple query (no changes needed for injection)
  static const String deviceImeiQuery = r'''
    query {
      devices { imei }
    }
  ''';
}
