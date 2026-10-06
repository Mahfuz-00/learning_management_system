import 'package:equatable/equatable.dart';

/// Base class for checkout events.
abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the price quote and the list of company discounts for a course.
///
/// Fired when the checkout page opens so the student immediately sees the
/// correct price under **Rule 4**.
class LoadCheckoutQuote extends CheckoutEvent {
  final String courseId;
  const LoadCheckoutQuote(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

/// Applies (or clears) a coupon code and re-requests the quote.
///
/// The client never computes the new price itself — it asks the server, because
/// only the server knows whether this coupon beats the corporate offer in Taka.
class ApplyCouponCode extends CheckoutEvent {
  final String courseId;
  final String couponCode;
  const ApplyCouponCode({required this.courseId, required this.couponCode});

  @override
  List<Object?> get props => [courseId, couponCode];
}

/// Selects a company discount ("Pay via") and re-requests the quote.
class SelectCorporateCoupon extends CheckoutEvent {
  final String courseId;
  final String? corporateCouponId;
  const SelectCorporateCoupon({
    required this.courseId,
    required this.corporateCouponId,
  });

  @override
  List<Object?> get props => [courseId, corporateCouponId];
}

/// Starts the SSLCommerz payment.
class InitiateCheckoutPayment extends CheckoutEvent {
  final String courseId;
  final String? phone;
  const InitiateCheckoutPayment({required this.courseId, this.phone});

  @override
  List<Object?> get props => [courseId, phone];
}

/// Clears the one-shot success flag after the UI has shown its snackbar.
class ClearCheckoutFeedback extends CheckoutEvent {
  const ClearCheckoutFeedback();
}