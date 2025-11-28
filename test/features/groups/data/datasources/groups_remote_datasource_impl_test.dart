import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/constants/api_routes.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/features/groups/data/datasources/groups_remote_datasource_impl.dart';
import 'package:sincro/features/groups/data/models/invitation_model.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late GroupsRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = GroupsRemoteDataSourceImpl(mockDioClient);
  });

  group('GroupsRemoteDataSourceImpl', () {
    final tGroupModel = GroupModel(
      id: 1,
      name: 'Test Group',
      description: 'Test Description',
      membersCount: 5,
      createdAt: DateTime(2024, 1, 1),
      role: GroupRole.owner,
    );

    final tGroupJson = {
      'id': 1,
      'name': 'Test Group',
      'description': 'Test Description',
      'members_count': 5,
      'created_at': '2024-01-01T00:00:00.000Z',
      'role': 'owner',
    };

    group('getGroups', () {
      final tPaginatedResponse = {
        'data': [tGroupJson],
        'meta': {
          'current_page': 1,
          'last_page': 1,
          'per_page': 15,
          'total': 1,
        },
      };

      test(
        'should return PaginatedResponse<GroupModel> when successful',
        () async {
          // arrange
          when(
            mockDioClient.get(
              ApiRoutes.groups,
              queryParameters: {'page': 1},
            ),
          ).thenReturn(
            TaskEither.right(
              Response(
                data: tPaginatedResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: ApiRoutes.groups),
              ),
            ),
          );

          // act
          final result = await dataSource.getGroups(page: 1).run();

          // assert
          expect(result.isRight(), true);
          result.fold(
            (l) => fail('Should be right'),
            (r) {
              expect(r.data.length, equals(1));
              expect(r.data.first.id, equals(tGroupModel.id));
              expect(r.data.first.name, equals(tGroupModel.name));
            },
          );
          verify(
            mockDioClient.get(
              ApiRoutes.groups,
              queryParameters: {'page': 1},
            ),
          ).called(1);
        },
      );

      test('should include perPage when provided', () async {
        // arrange
        when(
          mockDioClient.get(
            ApiRoutes.groups,
            queryParameters: {'page': 1, 'per_page': 10},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tPaginatedResponse,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.groups),
            ),
          ),
        );

        // act
        final result = await dataSource.getGroups(page: 1, perPage: 10).run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.get(
            ApiRoutes.groups,
            queryParameters: {'page': 1, 'per_page': 10},
          ),
        ).called(1);
      });

      test('should return failure when api call fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Server error');

        when(
          mockDioClient.get(
            ApiRoutes.groups,
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource.getGroups(page: 1).run();

        // assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, equals(tFailure)),
          (r) => fail('Should be left'),
        );
      });
    });

    group('createGroup', () {
      test('should return GroupModel when creation is successful', () async {
        // arrange
        when(
          mockDioClient.post(
            ApiRoutes.groups,
            data: {'name': 'Test Group', 'description': 'Test Description'},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tGroupJson,
              statusCode: 201,
              requestOptions: RequestOptions(path: ApiRoutes.groups),
            ),
          ),
        );

        // act
        final result = await dataSource
            .createGroup(
              name: 'Test Group',
              description: 'Test Description',
            )
            .run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.name, equals(tGroupModel.name));
            expect(r.description, equals(tGroupModel.description));
          },
        );
      });

      test('should include initial_members when provided', () async {
        // arrange
        when(
          mockDioClient.post(
            ApiRoutes.groups,
            data: {
              'name': 'Test Group',
              'initial_members': ['email@test.com'],
            },
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tGroupJson,
              statusCode: 201,
              requestOptions: RequestOptions(path: ApiRoutes.groups),
            ),
          ),
        );

        // act
        final result = await dataSource
            .createGroup(
              name: 'Test Group',
              initialMembers: ['email@test.com'],
            )
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.post(
            ApiRoutes.groups,
            data: {
              'name': 'Test Group',
              'initial_members': ['email@test.com'],
            },
          ),
        ).called(1);
      });

      test('should return failure when creation fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Creation failed');

        when(
          mockDioClient.post(
            ApiRoutes.groups,
            data: anyNamed('data'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await dataSource.createGroup(name: 'Test').run();

        // assert
        expect(result.isLeft(), true);
      });
    });

    group('getGroup', () {
      test('should return GroupModel when successful', () async {
        // arrange
        when(
          mockDioClient.get(ApiRoutes.groupById('1')),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tGroupJson,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.groupById('1')),
            ),
          ),
        );

        // act
        final result = await dataSource.getGroup('1').run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) => expect(r.id, equals(1)),
        );
        verify(mockDioClient.get(ApiRoutes.groupById('1'))).called(1);
      });
    });

    group('updateGroup', () {
      test('should return GroupModel when update is successful', () async {
        // arrange
        when(
          mockDioClient.put(
            ApiRoutes.groupById('1'),
            data: {'name': 'Updated Name'},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {...tGroupJson, 'name': 'Updated Name'},
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.groupById('1')),
            ),
          ),
        );

        // act
        final result = await dataSource
            .updateGroup(
              id: '1',
              name: 'Updated Name',
            )
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.put(
            ApiRoutes.groupById('1'),
            data: {'name': 'Updated Name'},
          ),
        ).called(1);
      });

      test('should include all optional parameters when provided', () async {
        // arrange
        when(
          mockDioClient.put(
            ApiRoutes.groupById('1'),
            data: {
              'name': 'Updated Name',
              'description': 'Updated Description',
              'members_can_add_transactions': true,
              'members_can_invite': false,
            },
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tGroupJson,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.groupById('1')),
            ),
          ),
        );

        // act
        final result = await dataSource
            .updateGroup(
              id: '1',
              name: 'Updated Name',
              description: 'Updated Description',
              membersCanAddTransactions: true,
              membersCanInvite: false,
            )
            .run();

        // assert
        expect(result.isRight(), true);
      });
    });

    group('deleteGroup', () {
      test('should return void when deletion is successful', () async {
        // arrange
        when(
          mockDioClient.delete(ApiRoutes.groupById('1')),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.groupById('1')),
            ),
          ),
        );

        // act
        final result = await dataSource.deleteGroup('1').run();

        // assert
        expect(result.isRight(), true);
        verify(mockDioClient.delete(ApiRoutes.groupById('1'))).called(1);
      });
    });

    group('getGroupTransactions', () {
      final tTransactionJson = {
        'id': 1,
        'title': 'Transaction',
        'amount': 100.0,
        'type': 'expense',
        'category': 'Food',
        'transaction_date': '2024-01-01T00:00:00.000Z',
        'created_at': '2024-01-01T00:00:00.000Z',
        'user_id': 1,
        'user_name': 'Test User',
      };

      final tPaginatedTransactions = {
        'data': [tTransactionJson],
        'meta': {
          'current_page': 1,
          'last_page': 1,
          'per_page': 15,
          'total': 1,
        },
      };

      test('should return paginated transactions when successful', () async {
        // arrange
        when(
          mockDioClient.get(
            ApiRoutes.groupTransactions('1'),
            queryParameters: {'page': 1},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tPaginatedTransactions,
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiRoutes.groupTransactions('1'),
              ),
            ),
          ),
        );

        // act
        final result = await dataSource
            .getGroupTransactions(groupId: '1', page: 1)
            .run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.data.length, equals(1));
            expect(r.data.first.title, equals('Transaction'));
          },
        );
      });
    });

    group('getGroupMembers', () {
      final tMembersJson = {
        'data': [
          {
            'id': 1,
            'name': 'Member 1',
            'email': 'member1@test.com',
            'role': 'owner',
          },
          {
            'id': 2,
            'name': 'Member 2',
            'email': 'member2@test.com',
            'role': 'member',
          },
        ],
      };

      test('should return list of GroupMemberModel when successful', () async {
        // arrange
        when(
          mockDioClient.get(ApiRoutes.groupMembers('1')),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tMembersJson,
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.groupMembers('1')),
            ),
          ),
        );

        // act
        final result = await dataSource.getGroupMembers('1').run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.length, equals(2));
            expect(r.first.name, equals('Member 1'));
            expect(r.first.role, equals(GroupRole.owner));
          },
        );
      });
    });

    group('removeMember', () {
      test('should return void when removal is successful', () async {
        // arrange
        when(
          mockDioClient.delete(ApiRoutes.groupMemberAction('1', 2)),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiRoutes.groupMemberAction('1', 2),
              ),
            ),
          ),
        );

        // act
        final result = await dataSource
            .removeMember(groupId: '1', userId: 2)
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.delete(ApiRoutes.groupMemberAction('1', 2)),
        ).called(1);
      });
    });

    group('updateMemberRole', () {
      test('should return void when role update is successful', () async {
        // arrange
        when(
          mockDioClient.patch(
            ApiRoutes.groupMemberAction('1', 2),
            data: {'role': 'admin'},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiRoutes.groupMemberAction('1', 2),
              ),
            ),
          ),
        );

        // act
        final result = await dataSource
            .updateMemberRole(groupId: '1', userId: 2, role: 'admin')
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.patch(
            ApiRoutes.groupMemberAction('1', 2),
            data: {'role': 'admin'},
          ),
        ).called(1);
      });
    });

    group('sendInvite', () {
      test('should return void when invite is sent successfully', () async {
        // arrange
        when(
          mockDioClient.post(
            ApiRoutes.groupInvites('1'),
            data: {'email': 'test@example.com'},
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.groupInvites('1')),
            ),
          ),
        );

        // act
        final result = await dataSource
            .sendInvite(groupId: '1', email: 'test@example.com')
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.post(
            ApiRoutes.groupInvites('1'),
            data: {'email': 'test@example.com'},
          ),
        ).called(1);
      });
    });

    group('getPendingInvites', () {
      final tInvitesJson = {
        'data': [
          {
            'id': 1,
            'status': 'pending',
            'group': tGroupJson,
            'inviter': {
              'id': 1,
              'name': 'Inviter',
              'email': 'inviter@test.com',
            },
            'created_at': '2024-01-01T00:00:00.000Z',
          },
        ],
      };

      test('should return list of InvitationModel when successful', () async {
        // arrange
        when(
          mockDioClient.get(ApiRoutes.invitationsPending),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tInvitesJson,
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiRoutes.invitationsPending,
              ),
            ),
          ),
        );

        // act
        final result = await dataSource.getPendingInvites().run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.length, equals(1));
            expect(r.first.status, equals(InvitationStatus.pending));
          },
        );
      });

      test('should handle response without data wrapper', () async {
        // arrange
        final tDirectInvites = [
          {
            'id': 1,
            'status': 'pending',
            'group': tGroupJson,
            'inviter': {
              'id': 1,
              'name': 'Inviter',
              'email': 'inviter@test.com',
            },
            'created_at': '2024-01-01T00:00:00.000Z',
          },
        ];

        when(
          mockDioClient.get(ApiRoutes.invitationsPending),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: tDirectInvites,
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiRoutes.invitationsPending,
              ),
            ),
          ),
        );

        // act
        final result = await dataSource.getPendingInvites().run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) => expect(r.length, equals(1)),
        );
      });
    });

    group('acceptInvite', () {
      test('should return void when invite is accepted successfully', () async {
        // arrange
        when(
          mockDioClient.post(ApiRoutes.invitationAccept(1)),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiRoutes.invitationAccept(1),
              ),
            ),
          ),
        );

        // act
        final result = await dataSource.acceptInvite(1).run();

        // assert
        expect(result.isRight(), true);
        verify(mockDioClient.post(ApiRoutes.invitationAccept(1))).called(1);
      });
    });

    group('declineInvite', () {
      test('should return void when invite is declined successfully', () async {
        // arrange
        when(
          mockDioClient.post(ApiRoutes.invitationDecline(1)),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiRoutes.invitationDecline(1),
              ),
            ),
          ),
        );

        // act
        final result = await dataSource.declineInvite(1).run();

        // assert
        expect(result.isRight(), true);
        verify(mockDioClient.post(ApiRoutes.invitationDecline(1))).called(1);
      });
    });

    group('clearHistory', () {
      test('should return void when history is cleared successfully', () async {
        // arrange
        when(
          mockDioClient.delete(ApiRoutes.groupClearHistory('1')),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(
                path: ApiRoutes.groupClearHistory('1'),
              ),
            ),
          ),
        );

        // act
        final result = await dataSource.clearHistory('1').run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.delete(ApiRoutes.groupClearHistory('1')),
        ).called(1);
      });
    });

    group('exportGroup', () {
      test('should return void when export is successful', () async {
        // arrange
        when(
          mockDioClient.download(
            ApiRoutes.groupExport('1'),
            '/path/to/save',
          ),
        ).thenReturn(
          TaskEither.right(
            Response(
              data: {},
              statusCode: 200,
              requestOptions: RequestOptions(path: ApiRoutes.groupExport('1')),
            ),
          ),
        );

        // act
        final result = await dataSource
            .exportGroup(groupId: '1', savePath: '/path/to/save')
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDioClient.download(
            ApiRoutes.groupExport('1'),
            '/path/to/save',
          ),
        ).called(1);
      });
    });
  });
}
