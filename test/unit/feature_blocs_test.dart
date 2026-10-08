// Unit tests for the feature BLoCs that manage state beyond auth and courses:
// Notification, Progress, Refund, Store and Preference.
//
// Each drives the real BLoC through its real events against a fake repository
// and asserts the emitted states.

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Core/Error/failures.dart';
import 'package:lms_touch_and_solve/Domain/Entities/payment_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/progress_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/refund_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/store_item_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/user_preference_entity.dart';
import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/preference_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Notifications/Bloc/notification_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Notifications/Bloc/notification_event.dart';
import 'package:lms_touch_and_solve/Presentation/Notifications/Bloc/notification_state.dart';
import 'package:lms_touch_and_solve/Presentation/Progress/Bloc/progress_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Progress/Bloc/progress_event.dart';
import 'package:lms_touch_and_solve/Presentation/Progress/Bloc/progress_state.dart';
import 'package:lms_touch_and_solve/Presentation/Refund/Bloc/refund_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Refund/Bloc/refund_event.dart';
import 'package:lms_touch_and_solve/Presentation/Refund/Bloc/refund_state.dart';
import 'package:lms_touch_and_solve/Presentation/Student/Bloc/store_bloc.dart';

import '../helpers/fakes.dart';

void main() {
  // ── Notifications ─────────────────────────────────────────────────────────
  group('NotificationBloc', () {
    test('loads notifications and the unread count together', () async {
      final repo = FakeLearningRepository(
        notificationsResult: Right([
          buildNotification(id: 'n1'),
          buildNotification(id: 'n2', isRead: true),
        ]),
        unreadCountResult: const Right(1),
      );
      final bloc = NotificationBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadNotifications());
      final state = await bloc.stream
          .firstWhere((s) => s.status == NotificationStatus.loaded);

      expect(state.notifications, hasLength(2));
      expect(state.unreadCount, 1);
    });

    test('a failed list load sets an error status', () async {
      final repo = FakeLearningRepository(
        notificationsResult: const Left(ServerFailure('down')),
      );
      final bloc = NotificationBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadNotifications());
      final state = await bloc.stream
          .firstWhere((s) => s.status == NotificationStatus.error);

      expect(state.errorMessage, 'down');
    });

    test('marking one read updates the item and recomputes the badge',
        () async {
      final repo = FakeLearningRepository(
        notificationsResult: Right([
          buildNotification(id: 'n1'),
          buildNotification(id: 'n2'),
        ]),
        unreadCountResult: const Right(2),
      );
      final bloc = NotificationBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadNotifications());
      await bloc.stream.firstWhere((s) => s.status == NotificationStatus.loaded);

      bloc.add(const MarkNotificationRead('n1'));
      final state = await bloc.stream.firstWhere((s) => s.unreadCount == 1);

      expect(state.notifications.firstWhere((n) => n.id == 'n1').isRead, isTrue);
      expect(repo.markedReadIds, ['n1']);
    });

    test('mark-all read clears the badge and marks every item', () async {
      final repo = FakeLearningRepository(
        notificationsResult: Right([
          buildNotification(id: 'n1'),
          buildNotification(id: 'n2'),
        ]),
        unreadCountResult: const Right(2),
      );
      final bloc = NotificationBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadNotifications());
      await bloc.stream.firstWhere((s) => s.status == NotificationStatus.loaded);

      bloc.add(MarkAllNotificationsRead());
      final state = await bloc.stream.firstWhere((s) => s.unreadCount == 0);

      expect(state.notifications.every((n) => n.isRead), isTrue);
      expect(repo.markAllReadCalls, 1);
    });

    test('refreshing the badge count does not disturb the list', () async {
      final repo = FakeLearningRepository(
        notificationsResult: Right([buildNotification(id: 'n1')]),
        unreadCountResult: const Right(1),
      );
      final bloc = NotificationBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadNotifications());
      await bloc.stream.firstWhere((s) => s.status == NotificationStatus.loaded);

      // The server now reports a different count; the poll must pick it up while
      // leaving the list untouched.
      repo.unreadCountResult = const Right(7);
      bloc.add(RefreshUnreadCount());
      final state = await bloc.stream.firstWhere((s) => s.unreadCount == 7);

      expect(state.notifications, hasLength(1));
    });
  });

  // ── Progress ──────────────────────────────────────────────────────────────
  group('ProgressBloc', () {
    test('loads the progress dashboard', () async {
      final repo = FakeLearningRepository(
        progressResult: Right([
          const CourseProgressEntity(
            courseId: 'c1',
            courseTitle: 'Flutter',
            videoProgress: 40,
            quizProgress: 15,
            examProgress: 15,
            liveExamProgress: 20,
            attendanceProgress: 10,
          ),
        ]),
      );
      final bloc = ProgressBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadMyProgress());
      final state = await bloc.stream
          .firstWhere((s) => s.status == ProgressStatus.loaded);

      expect(state.courseProgress.single.effectiveOverall, 100);
    });

    test('a failed progress load surfaces the error', () async {
      final repo = FakeLearningRepository(
        progressResult: const Left(ServerFailure('nope')),
      );
      final bloc = ProgressBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadMyProgress());
      final state = await bloc.stream
          .firstWhere((s) => s.status == ProgressStatus.error);

      expect(state.errorMessage, 'nope');
    });

    test('watch history is sorted newest first', () async {
      final repo = FakeLearningRepository(
        historyResult: Right([
          buildHistoryItem(id: 'old', contentId: 'a', lastWatchedAt: DateTime(2026, 1, 1)),
          buildHistoryItem(id: 'new', contentId: 'b', lastWatchedAt: DateTime(2026, 6, 1)),
        ]),
      );
      final bloc = ProgressBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(const LoadWatchHistory('u1'));
      final state = await bloc.stream
          .firstWhere((s) => s.status == ProgressStatus.loaded);

      expect(state.history.first.contentId, 'b');
    });

    test('hiding an item marks it hidden locally and keeps its progress', () async {
      final repo = FakeLearningRepository(
        historyResult: Right([buildHistoryItem(id: 'h1', contentId: 'a')]),
      );
      final bloc = ProgressBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(const LoadWatchHistory('u1'));
      await bloc.stream.firstWhere((s) => s.status == ProgressStatus.loaded);

      bloc.add(const HideHistoryItem(userId: 'u1', contentId: 'a'));
      final state =
          await bloc.stream.firstWhere((s) => s.history.first.isHidden);

      expect(repo.hideCalls, 1);
      expect(state.history.first.watchedSeconds, 300);
    });

    test('restoring an item unhides it', () async {
      final repo = FakeLearningRepository(
        historyResult: Right([
          buildHistoryItem(id: 'h1', contentId: 'a', isHidden: true),
        ]),
      );
      final bloc = ProgressBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(const LoadWatchHistory('u1'));
      await bloc.stream.firstWhere((s) => s.status == ProgressStatus.loaded);

      bloc.add(const RestoreHistoryItem(userId: 'u1', contentId: 'a'));
      final state =
          await bloc.stream.firstWhere((s) => !s.history.first.isHidden);

      expect(repo.restoreCalls, 1);
    });
  });

  // ── Refunds ───────────────────────────────────────────────────────────────
  group('RefundBloc', () {
    test('loads eligibility', () async {
      final repo = FakeLearningRepository(
        eligibilityResult: const Right(RefundEligibilityEntity(
          isEligible: true,
          reason: 'Within 7 days',
        )),
      );
      final bloc = RefundBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(const LoadRefundEligibility('c1'));
      final state = await bloc.stream
          .firstWhere((s) => s.status == RefundLoadStatus.loaded);

      expect(state.eligibility?.isEligible, isTrue);
    });

    test('requesting a refund prepends it to the list', () async {
      final repo = FakeLearningRepository(
        requestRefundResult: Right(buildRefund(id: 'r-new')),
      );
      final bloc = RefundBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(const RequestRefund(courseId: 'c1', reason: 'Changed mind'));
      final state = await bloc.stream.firstWhere((s) => s.actionSucceeded);

      expect(state.refunds.first.id, 'r-new');
    });

    test('a failed request reports the error and does not flag success',
        () async {
      final repo = FakeLearningRepository(
        requestRefundResult: const Left(ServerFailure('Not eligible')),
      );
      final bloc = RefundBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(const RequestRefund(courseId: 'c1', reason: 'x'));
      final state = await bloc.stream
          .firstWhere((s) => s.status == RefundLoadStatus.error);

      expect(state.errorMessage, 'Not eligible');
      expect(state.actionSucceeded, isFalse);
    });

    test('cancelling a refund removes it from the list', () async {
      final repo = FakeLearningRepository(
        myRefundsResult: Right([buildRefund(id: 'r1'), buildRefund(id: 'r2')]),
      );
      final bloc = RefundBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadMyRefunds());
      await bloc.stream.firstWhere((s) => s.status == RefundLoadStatus.loaded);
      expect(bloc.state.refunds, hasLength(2));

      bloc.add(const CancelRefund('r1'));
      final state = await bloc.stream
          .firstWhere((s) => s.refunds.every((r) => r.id != 'r1'));

      expect(state.refunds.single.id, 'r2');
    });
  });

  // ── Store ─────────────────────────────────────────────────────────────────
  group('StoreBloc', () {
    test('loads store items', () async {
      final repo = FakeStoreRepository(
        itemsResult: const Right([
          StoreItemEntity(id: 's1', title: 'Book', price: 500),
        ]),
      );
      final bloc = StoreBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadStoreItems());
      final state = await bloc.stream.firstWhere((s) => s is StoreLoaded);

      expect((state as StoreLoaded).items.single.title, 'Book');
    });

    test('a failed load emits StoreError', () async {
      final repo = FakeStoreRepository(
        itemsResult: const Left(ServerFailure('store down')),
      );
      final bloc = StoreBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadStoreItems());
      final state = await bloc.stream.firstWhere((s) => s is StoreError);

      expect((state as StoreError).message, 'store down');
    });
  });

  // ── Preferences ───────────────────────────────────────────────────────────
  group('PreferenceBloc', () {
    test('loading preferences emits PreferenceLoaded', () async {
      final repo = FakeCourseRepository();
      repo.preferencesResult = const Right(UserPreferenceEntity(
        categories: ['Math'],
        learningGoal: 'Exam',
        dailyTime: '1h',
      ));
      final bloc = PreferenceBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadPreferencesRequested());
      final state = await bloc.stream.firstWhere((s) => s is PreferenceLoaded);

      expect((state as PreferenceLoaded).preferences.categories, ['Math']);
    });

    test('saving preferences emits PreferenceSaved', () async {
      final repo = FakeCourseRepository();
      final bloc = PreferenceBloc(repository: repo);
      addTearDown(bloc.close);

      bloc.add(const SavePreferencesRequested(UserPreferenceEntity(
        categories: ['A'],
        learningGoal: 'g',
        dailyTime: 'd',
      )));

      expect(await bloc.stream.firstWhere((s) => s is PreferenceSaved),
          isA<PreferenceSaved>());
    });
  });

  // ── Payment quote (Rule 4) ────────────────────────────────────────────────
  group('PaymentQuoteModel via repository', () {
    test('the applied discount wins and the rest are retained', () {
      const quote = PaymentQuoteEntity(
        originalPrice: 1000,
        appliedDiscount: DiscountOfferEntity(
          source: DiscountSource.coupon,
          label: 'EID',
          amountInTaka: 300,
          isApplied: true,
        ),
        payableAmount: 700,
      );
      expect(quote.totalSavings, 300);
      expect(quote.allOffers.where((o) => o.isApplied).length, 1);
    });
  });
}
