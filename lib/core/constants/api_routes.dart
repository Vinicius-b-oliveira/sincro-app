class ApiRoutes {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  static const String userProfile = '/user';
  static const String userPreferences = '/user/preferences';
  static const String updatePassword = '/user/password';

  static const String transactions = '/transactions';
  static String transactionById(int id) => '$transactions/$id';

  static const String groups = '/groups';
  static String groupById(String id) => '$groups/$id';

  static String groupMembers(String id) => '$groups/$id/members';

  static String groupMemberAction(String groupId, int userId) =>
      '$groups/$groupId/members/$userId';

  static const String invitationsPending = '/invitations/pending';
  static String invitationAccept(int id) => '/invitations/$id/accept';
  static String invitationDecline(int id) => '/invitations/$id/decline';

  static String groupInvites(String id) => '/groups/$id/invitations';

  static String groupTransactions(String id) => '$groups/$id/transactions';

  static const String balance = '/balance';
  static const String summary = '/analytics/summary';

  static String groupExport(String id) => '$groups/$id/export';
  static String groupClearHistory(String id) => '$groups/$id/history';

  static const Set<String> publicEndpoints = {
    login,
    register,
    refreshToken,
  };
}
