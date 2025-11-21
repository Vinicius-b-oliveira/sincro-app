class ApiRoutes {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String userProfile = '/user';
  static const String userPreferences = '/user/preferences';
  static const String updatePassword = '/user/password';

  static const Set<String> publicEndpoints = {
    login,
    register,
    refreshToken,
  };
}
