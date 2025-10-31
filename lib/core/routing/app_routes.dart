class AppRoutes {
  static const String splash = '/splash';

  static const String login = '/login';
  static const String signup = '/signup';

  static const String home = '/';
  static const String history = '/history';
  static const String groups = '/groups';
  static const String createGroup = '/groups/create';
  static const String groupInvites = '/groups/invites';
  static const String groupDetails = '/groups/:id';
  static const String groupMembers = '/groups/:id/members';
  static const String groupEdit = '/groups/:id/edit';
  static const String groupSettings = '/groups/:id/settings';
  static const String profile = '/profile';

  static const String addTransaction = '/add-transaction';

  static const Set<String> publicRoutes = {
    splash,
    login,
    signup,
  };
}
