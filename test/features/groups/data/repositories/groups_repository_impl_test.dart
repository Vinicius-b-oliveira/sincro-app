import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:sincro/core/enums/transaction_type.dart';
import 'package:sincro/core/errors/app_failure.dart';
import 'package:sincro/core/models/group_model.dart';
import 'package:sincro/core/models/paginated_response.dart';
import 'package:sincro/core/models/transaction_model.dart';
import 'package:sincro/core/models/user_model.dart';
import 'package:sincro/features/groups/data/models/group_member_model.dart';
import 'package:sincro/features/groups/data/models/invitation_model.dart';
import 'package:sincro/features/groups/data/repositories/groups_repository_impl.dart';

import '../../../../mocks/mock_helpers.dart';
import '../../../../mocks/mocks.mocks.dart';

void main() {
  late GroupsRepositoryImpl repository;
  late MockGroupsRemoteDataSource mockDataSource;

  setUpAll(() {
    setupMockDummies();
  });

  setUp(() {
    mockDataSource = MockGroupsRemoteDataSource();
    repository = GroupsRepositoryImpl(mockDataSource);
  });

  group('GroupsRepositoryImpl', () {
    final tGroupModel = GroupModel(
      id: 1,
      name: 'Test Group',
      description: 'Test Description',
      membersCount: 5,
      createdAt: DateTime(2024, 1, 1),
      role: GroupRole.owner,
    );

    final tMetaData = const MetaData(
      currentPage: 1,
      lastPage: 1,
      perPage: 15,
      total: 1,
    );

    group('getGroups', () {
      test('should delegate call to datasource', () async {
        // arrange
        final tPaginatedResponse = PaginatedResponse<GroupModel>(
          data: [tGroupModel],
          meta: tMetaData,
        );

        when(
          mockDataSource.getGroups(page: 1, perPage: 10),
        ).thenReturn(TaskEither.right(tPaginatedResponse));

        // act
        final result = await repository.getGroups(page: 1, perPage: 10).run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.data.length, equals(1));
            expect(r.data.first.id, equals(tGroupModel.id));
          },
        );
        verify(mockDataSource.getGroups(page: 1, perPage: 10)).called(1);
      });

      test('should return failure when datasource fails', () async {
        // arrange
        final tFailure = ServerFailure(message: 'Server error');

        when(
          mockDataSource.getGroups(
            page: anyNamed('page'),
            perPage: anyNamed('perPage'),
          ),
        ).thenReturn(TaskEither.left(tFailure));

        // act
        final result = await repository.getGroups(page: 1).run();

        // assert
        expect(result.isLeft(), true);
      });
    });

    group('createGroup', () {
      test('should delegate call to datasource with all parameters', () async {
        // arrange
        when(
          mockDataSource.createGroup(
            name: 'Test Group',
            description: 'Test Description',
            initialMembers: ['email@test.com'],
          ),
        ).thenReturn(TaskEither.right(tGroupModel));

        // act
        final result = await repository
            .createGroup(
              name: 'Test Group',
              description: 'Test Description',
              initialMembers: ['email@test.com'],
            )
            .run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) => expect(r.id, equals(tGroupModel.id)),
        );
        verify(
          mockDataSource.createGroup(
            name: 'Test Group',
            description: 'Test Description',
            initialMembers: ['email@test.com'],
          ),
        ).called(1);
      });
    });

    group('getGroup', () {
      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockDataSource.getGroup('1'),
        ).thenReturn(TaskEither.right(tGroupModel));

        // act
        final result = await repository.getGroup('1').run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) => expect(r.id, equals(tGroupModel.id)),
        );
        verify(mockDataSource.getGroup('1')).called(1);
      });
    });

    group('updateGroup', () {
      test('should delegate call to datasource with all parameters', () async {
        // arrange
        when(
          mockDataSource.updateGroup(
            id: '1',
            name: 'Updated Name',
            description: 'Updated Description',
            membersCanAddTransactions: true,
            membersCanInvite: false,
          ),
        ).thenReturn(TaskEither.right(tGroupModel));

        // act
        final result = await repository
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
        verify(
          mockDataSource.updateGroup(
            id: '1',
            name: 'Updated Name',
            description: 'Updated Description',
            membersCanAddTransactions: true,
            membersCanInvite: false,
          ),
        ).called(1);
      });
    });

    group('deleteGroup', () {
      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockDataSource.deleteGroup('1'),
        ).thenReturn(TaskEither.right(null));

        // act
        final result = await repository.deleteGroup('1').run();

        // assert
        expect(result.isRight(), true);
        verify(mockDataSource.deleteGroup('1')).called(1);
      });
    });

    group('getGroupTransactions', () {
      final tTransaction = TransactionModel(
        id: 1,
        title: 'Transaction',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'Food',
        date: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
        userId: 1,
        userName: 'Test User',
      );

      test('should delegate call to datasource', () async {
        // arrange
        final tPaginatedResponse = PaginatedResponse<TransactionModel>(
          data: [tTransaction],
          meta: tMetaData,
        );

        when(
          mockDataSource.getGroupTransactions(groupId: '1', page: 1),
        ).thenReturn(TaskEither.right(tPaginatedResponse));

        // act
        final result = await repository
            .getGroupTransactions(groupId: '1', page: 1)
            .run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) => expect(r.data.length, equals(1)),
        );
        verify(
          mockDataSource.getGroupTransactions(groupId: '1', page: 1),
        ).called(1);
      });
    });

    group('getGroupMembers', () {
      final tMember = const GroupMemberModel(
        id: 1,
        name: 'Member',
        email: 'member@test.com',
        role: GroupRole.member,
      );

      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockDataSource.getGroupMembers('1'),
        ).thenReturn(TaskEither.right([tMember]));

        // act
        final result = await repository.getGroupMembers('1').run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.length, equals(1));
            expect(r.first.name, equals(tMember.name));
          },
        );
        verify(mockDataSource.getGroupMembers('1')).called(1);
      });
    });

    group('removeMember', () {
      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockDataSource.removeMember(groupId: '1', userId: 2),
        ).thenReturn(TaskEither.right(null));

        // act
        final result = await repository
            .removeMember(groupId: '1', userId: 2)
            .run();

        // assert
        expect(result.isRight(), true);
        verify(mockDataSource.removeMember(groupId: '1', userId: 2)).called(1);
      });
    });

    group('updateMemberRole', () {
      test('should delegate call to datasource with role name', () async {
        // arrange
        when(
          mockDataSource.updateMemberRole(
            groupId: '1',
            userId: 2,
            role: 'admin',
          ),
        ).thenReturn(TaskEither.right(null));

        // act
        final result = await repository
            .updateMemberRole(
              groupId: '1',
              userId: 2,
              role: GroupRole.admin,
            )
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDataSource.updateMemberRole(
            groupId: '1',
            userId: 2,
            role: 'admin',
          ),
        ).called(1);
      });
    });

    group('sendInvite', () {
      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockDataSource.sendInvite(groupId: '1', email: 'test@example.com'),
        ).thenReturn(TaskEither.right(null));

        // act
        final result = await repository
            .sendInvite(groupId: '1', email: 'test@example.com')
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDataSource.sendInvite(groupId: '1', email: 'test@example.com'),
        ).called(1);
      });
    });

    group('getPendingInvites', () {
      final tInvitation = InvitationModel(
        id: 1,
        status: InvitationStatus.pending,
        group: tGroupModel,
        inviter: const UserModel(
          id: 1,
          name: 'Inviter',
          email: 'inviter@test.com',
        ),
        createdAt: DateTime(2024, 1, 1),
      );

      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockDataSource.getPendingInvites(),
        ).thenReturn(TaskEither.right([tInvitation]));

        // act
        final result = await repository.getPendingInvites().run();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should be right'),
          (r) {
            expect(r.length, equals(1));
            expect(r.first.status, equals(InvitationStatus.pending));
          },
        );
        verify(mockDataSource.getPendingInvites()).called(1);
      });
    });

    group('acceptInvite', () {
      test('should delegate call to datasource', () async {
        // arrange
        when(mockDataSource.acceptInvite(1)).thenReturn(TaskEither.right(null));

        // act
        final result = await repository.acceptInvite(1).run();

        // assert
        expect(result.isRight(), true);
        verify(mockDataSource.acceptInvite(1)).called(1);
      });
    });

    group('declineInvite', () {
      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockDataSource.declineInvite(1),
        ).thenReturn(TaskEither.right(null));

        // act
        final result = await repository.declineInvite(1).run();

        // assert
        expect(result.isRight(), true);
        verify(mockDataSource.declineInvite(1)).called(1);
      });
    });

    group('clearHistory', () {
      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockDataSource.clearHistory('1'),
        ).thenReturn(TaskEither.right(null));

        // act
        final result = await repository.clearHistory('1').run();

        // assert
        expect(result.isRight(), true);
        verify(mockDataSource.clearHistory('1')).called(1);
      });
    });

    group('exportGroup', () {
      test('should delegate call to datasource', () async {
        // arrange
        when(
          mockDataSource.exportGroup(groupId: '1', savePath: '/path/to/save'),
        ).thenReturn(TaskEither.right(null));

        // act
        final result = await repository
            .exportGroup(groupId: '1', savePath: '/path/to/save')
            .run();

        // assert
        expect(result.isRight(), true);
        verify(
          mockDataSource.exportGroup(groupId: '1', savePath: '/path/to/save'),
        ).called(1);
      });
    });
  });
}
