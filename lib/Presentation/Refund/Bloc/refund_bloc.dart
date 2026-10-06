import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Domain/Repositories/learning_repository.dart';
import 'refund_event.dart';
import 'refund_state.dart';

/// Drives the student's refund flow.
///
/// **Rule 9 (User Manual):** *"When admin approves a refund, the enrolment is
/// **deleted**, not marked as cancelled. The student loses access immediately.
/// ... the system **records** the refund. It does not move any money. Someone
/// must send the money back by hand."*
///
/// The UI must therefore warn the student that requesting a refund puts their
/// access at risk and that the money is returned manually, outside the app.
class RefundBloc extends Bloc<RefundEvent, RefundState> {
  final LearningRepository repository;

  RefundBloc({required this.repository}) : super(const RefundState()) {
    on<LoadRefundEligibility>(_onLoadEligibility);
    on<RequestRefund>(_onRequestRefund);
    on<LoadMyRefunds>(_onLoadMyRefunds);
    on<CancelRefund>(_onCancelRefund);
    on<ClearRefundFeedback>(_onClearFeedback);
  }

  Future<void> _onLoadEligibility(
    LoadRefundEligibility event,
    Emitter<RefundState> emit,
  ) async {
    emit(state.copyWith(status: RefundLoadStatus.loading, clearError: true));
    final result = await repository.getRefundEligibility(event.courseId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: RefundLoadStatus.error,
        errorMessage: failure.message,
      )),
      (eligibility) => emit(state.copyWith(
        status: RefundLoadStatus.loaded,
        eligibility: eligibility,
      )),
    );
  }

  Future<void> _onRequestRefund(
    RequestRefund event,
    Emitter<RefundState> emit,
  ) async {
    emit(state.copyWith(
      status: RefundLoadStatus.submitting,
      clearError: true,
      actionSucceeded: false,
    ));
    final result = await repository.requestRefund(event.courseId, event.reason);
    result.fold(
      (failure) => emit(state.copyWith(
        status: RefundLoadStatus.error,
        errorMessage: failure.message,
      )),
      (refund) => emit(state.copyWith(
        status: RefundLoadStatus.loaded,
        actionSucceeded: true,
        refunds: [refund, ...state.refunds],
      )),
    );
  }

  Future<void> _onLoadMyRefunds(
    LoadMyRefunds event,
    Emitter<RefundState> emit,
  ) async {
    emit(state.copyWith(status: RefundLoadStatus.loading, clearError: true));
    final result = await repository.getMyRefunds();
    result.fold(
      (failure) => emit(state.copyWith(
        status: RefundLoadStatus.error,
        errorMessage: failure.message,
      )),
      (refunds) => emit(state.copyWith(
        status: RefundLoadStatus.loaded,
        refunds: refunds,
      )),
    );
  }

  Future<void> _onCancelRefund(
    CancelRefund event,
    Emitter<RefundState> emit,
  ) async {
    emit(state.copyWith(status: RefundLoadStatus.submitting, clearError: true));
    final result = await repository.cancelRefund(event.refundId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: RefundLoadStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: RefundLoadStatus.loaded,
        actionSucceeded: true,
        // Drop the cancelled request from the list.
        refunds: state.refunds.where((r) => r.id != event.refundId).toList(),
      )),
    );
  }

  Future<void> _onClearFeedback(
    ClearRefundFeedback event,
    Emitter<RefundState> emit,
  ) async {
    emit(state.copyWith(actionSucceeded: false, clearError: true));
  }
}