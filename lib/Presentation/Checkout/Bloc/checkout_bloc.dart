import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Domain/Repositories/learning_repository.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

/// Drives the purchase flow: price quote, coupon entry, company selection and
/// payment initiation.
///
/// **Rule 4 is enforced entirely by the server.** This BLoC's only job is to
/// pass the student's coupon/company choice to `POST /api/Payment/quote` and
/// store whatever breakdown comes back — including the losing offers, which the
/// UI renders greyed out and marked "not applied" because the User Manual says
/// *"That is deliberate — it shows the student the offer existed and why it was
/// not used."*
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final LearningRepository repository;

  CheckoutBloc({required this.repository}) : super(const CheckoutState()) {
    on<LoadCheckoutQuote>(_onLoadQuote);
    on<ApplyCouponCode>(_onApplyCoupon);
    on<SelectCorporateCoupon>(_onSelectCorporate);
    on<InitiateCheckoutPayment>(_onInitiatePayment);
    on<ClearCheckoutFeedback>(_onClearFeedback);
  }

  /// Fetches the quote plus the company discounts available for the course.
  Future<void> _onLoadQuote(
    LoadCheckoutQuote event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(status: CheckoutStatus.loading, clearError: true));

    final couponsResult =
        await repository.getCorporateCouponsForCourse(event.courseId);
    final quoteResult = await repository.getPaymentQuote(event.courseId);

    final coupons = couponsResult.fold(
      (_) => state.corporateCoupons,
      (value) => value,
    );

    quoteResult.fold(
      (failure) => emit(state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: failure.message,
        corporateCoupons: coupons,
      )),
      (quote) => emit(state.copyWith(
        status: CheckoutStatus.ready,
        quote: quote,
        corporateCoupons: coupons,
      )),
    );
  }

  /// Re-requests the quote with a coupon code applied.
  ///
  /// The coupon is **not** validated locally: a code that looks fine may still
  /// lose to a bigger company discount (Rule 4), and only the server can decide.
  Future<void> _onApplyCoupon(
    ApplyCouponCode event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(status: CheckoutStatus.loading, clearError: true));

    final result = await repository.getPaymentQuote(
      event.courseId,
      couponCode: event.couponCode,
      corporateCouponId: state.selectedCorporateCouponId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: failure.message,
      )),
      (quote) => emit(state.copyWith(
        status: CheckoutStatus.ready,
        quote: quote,
        couponCode: event.couponCode,
      )),
    );
  }

  /// Re-requests the quote with a company discount selected (or cleared).
  Future<void> _onSelectCorporate(
    SelectCorporateCoupon event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(status: CheckoutStatus.loading, clearError: true));

    final result = await repository.getPaymentQuote(
      event.courseId,
      couponCode: state.couponCode,
      corporateCouponId: event.corporateCouponId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: failure.message,
      )),
      (quote) => emit(state.copyWith(
        status: CheckoutStatus.ready,
        quote: quote,
        selectedCorporateCouponId: event.corporateCouponId,
      )),
    );
  }

  /// Starts payment.
  ///
  /// If the payable amount is zero the server enrolls the student directly and
  /// returns no gateway URL — the UI then skips the payment page entirely
  /// (Manual §4.2).
  Future<void> _onInitiatePayment(
    InitiateCheckoutPayment event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(status: CheckoutStatus.processing, clearError: true));

    final result = await repository.initiatePayment(
      courseId: event.courseId,
      couponCode: state.couponCode,
      corporateCouponId: state.selectedCorporateCouponId,
      phone: event.phone,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: failure.message,
      )),
      (initiation) {
        if (initiation.isInstantEnrollment) {
          emit(state.copyWith(
            status: CheckoutStatus.ready,
            enrolledInstantly: true,
            actionSucceeded: true,
          ));
        } else {
          emit(state.copyWith(
            status: CheckoutStatus.redirecting,
            gatewayUrl: initiation.gatewayUrl,
          ));
        }
      },
    );
  }

  /// Clears the one-shot success flag.
  Future<void> _onClearFeedback(
    ClearCheckoutFeedback event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(actionSucceeded: false, clearError: true));
  }
}