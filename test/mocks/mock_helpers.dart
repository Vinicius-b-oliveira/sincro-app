import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/analytics_summary_model.dart';
import 'package:sincro/core/models/balance_model.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/token_model.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/core/models/user_model.dart';
import 'package:sincro/features/auth/data/models/auth_response.dart';
import 'package:sincro/features/groups/data/models/group_member_model.dart';
import 'package:sincro/features/groups/data/models/invitation_model.dart';

void setupMockDummies() {
  final dummyResponse = Response(
    requestOptions: RequestOptions(path: ''),
    data: {},
  );

  final dummyUser = const UserModel(id: 0, name: '', email: '');

  final dummyToken = const TokenModel(
    accessToken: '',
    refreshToken: '',
  );

  final dummyAuthResponse = AuthResponse(
    user: dummyUser,
    tokens: dummyToken,
  );

  final dummySummary = AnalyticsSummaryModel(
    chartData: [],
    summaryStats: const SummaryStatsModel(
      totalSpent: 0,
      monthlyAverage: 0,
      maxSpent: 0,
      minSpent: 0,
    ),
  );

  final dummyBalance = const BalanceModel(
    totalBalance: 0,
    periodIncome: 0,
    periodExpenses: 0,
  );

  final dummyGroup = GroupModel(
    id: 0,
    name: '',
    createdAt: DateTime(2024),
  );

  final dummyMeta = const MetaData(
    currentPage: 1,
    lastPage: 1,
    perPage: 15,
    total: 0,
  );

  final dummyTransaction = TransactionModel(
    id: 0,
    title: '',
    amount: 0,
    type: TransactionType.expense,
    date: DateTime(2024),
    createdAt: DateTime(2024),
    userId: 0,
    userName: '',
  );

  final dummyMember = const GroupMemberModel(
    id: 0,
    name: '',
    email: '',
    role: GroupRole.member,
  );

  final dummyInvitation = InvitationModel(
    id: 0,
    status: InvitationStatus.pending,
    group: dummyGroup,
    inviter: dummyUser,
    createdAt: DateTime(2024),
  );

  provideDummy<TaskEither<AppFailure, Response>>(
    TaskEither.right(dummyResponse),
  );
  provideDummy<TaskEither<AppFailure, Response<dynamic>>>(
    TaskEither.right(dummyResponse),
  );
  provideDummy<TaskEither<AppFailure, void>>(TaskEither.right(null));
  provideDummy<TaskEither<AppFailure, UserModel>>(
    TaskEither.right(dummyUser),
  );
  provideDummy<TaskEither<AppFailure, UserModel?>>(
    TaskEither.right(dummyUser),
  );
  provideDummy<TaskEither<AppFailure, TokenModel?>>(
    TaskEither.right(dummyToken),
  );
  provideDummy<TaskEither<AppFailure, AuthResponse>>(
    TaskEither.right(dummyAuthResponse),
  );
  provideDummy<TaskEither<AppFailure, AnalyticsSummaryModel>>(
    TaskEither.right(dummySummary),
  );
  provideDummy<TaskEither<AppFailure, BalanceModel>>(
    TaskEither.right(dummyBalance),
  );
  provideDummy<TaskEither<AppFailure, GroupModel>>(
    TaskEither.right(dummyGroup),
  );
  provideDummy<TaskEither<AppFailure, PaginatedResponse<GroupModel>>>(
    TaskEither.right(PaginatedResponse(data: [dummyGroup], meta: dummyMeta)),
  );
  provideDummy<TaskEither<AppFailure, TransactionModel>>(
    TaskEither.right(dummyTransaction),
  );
  provideDummy<TaskEither<AppFailure, PaginatedResponse<TransactionModel>>>(
    TaskEither.right(
      PaginatedResponse(data: [dummyTransaction], meta: dummyMeta),
    ),
  );
  provideDummy<TaskEither<AppFailure, List<GroupMemberModel>>>(
    TaskEither.right([dummyMember]),
  );
  provideDummy<TaskEither<AppFailure, List<InvitationModel>>>(
    TaskEither.right([dummyInvitation]),
  );
}
