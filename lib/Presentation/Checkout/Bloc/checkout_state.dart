import 'package:equatable/equatable.dart';

import '../../../Domain/Entities/payment_entity.dart';

/// Load status for the checkout screen.
enum CheckoutStatus { initial, loading, ready, processing, redirecting, error }

/// State of the checkout flow.
///
/// Holds the **server's** quote verbatim. The client never recalculates the
/// price, because **Rule 4** ("the single largest saving wins, compared in
/// Taka") depends on campaign windows and corporate eligibility the client
/// cannot see.
class CheckoutState extends Equatable {
  final CheckoutStatus status;

  /// The authoritative price breakdown.
  final PaymentQuoteEntity? quote;

  /// Company discounts the student may choose under "Pay via".
  final List<CorporateCouponEntity> corporateCoupons;

  /// The coupon code currently entered by the student.
  final String? couponCode;

  /// The company discount currently selected.
  final String? selectedCorporateCouponId;

  /// URL of the SSLCommerz page to open in a WebView.
  final String? gatewayUrl;

  /// Set when the course was granted without payment (free or fully
  /// discounted) — the UI should go straight to My Courses.
  final bool enrolledInstantly;

  final String? errorMessage;

  /// One-shot flag so the UI can show a snackbar exactly once.
  final bool actionSucceeded;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.quote,
    this.corporateCoupons = const [],
    this.couponCode,
    this.selectedCorporateCouponId,
    this.gatewayUrl,
    this.enrolledInstantly = false,
    this.errorMessage,
    this.actionSucceeded = false,
  });

  /// True when nothing has to be paid (free course or 100% discount).
  ///
  /// Manual §4.2: *"If the price is zero, or a discount covers the full price,
  /// you are enrolled immediately with no payment page."*
  bool get isFree => quote?.canEnrollWithoutPayment ?? false;

  /// The amount to display as payable, formatted in Taka.
  double get payableAmount => quote?.payableAmount ?? 0;

  /// True when the server reported that a coupon code was invalid.
  bool get hasCouponError => errorMessage != null && couponCode != null;

  CheckoutState copyWith({
    CheckoutStatus? status,
    PaymentQuoteEntity? quote,
    List<CorporateCouponEntity>? corporateCoupons,
    String? couponCode,
    String? selectedCorporateCouponId,
    String? gatewayUrl,
    bool? enrolledInstantly,
    String? errorMessage,
    bool? actionSucceeded,
    bool clearError = false,
    bool clearCoupon = false,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      quote: quote ?? this.quote,
      corporateCoupons: corporateCoupons ?? this.corporateCoupons,
      couponCode: clearCoupon ? null : (couponCode ?? this.couponCode),
      selectedCorporateCouponId:
          selectedCorporateCouponId ?? this.selectedCorporateCouponId,
      gatewayUrl: gatewayUrl ?? this.gatewayUrl,
      enrolledInstantly: enrolledInstantly ?? this.enrolledInstantly,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionSucceeded: actionSucceeded ?? this.actionSucceeded,
    );
  }

  @override
  List<Object?> get props => [
        status,
        quote,
        corporateCoupons,
        couponCode,
        selectedCorporateCouponId,
        gatewayUrl,
        enrolledInstantly,
        errorMessage,
        actionSucceeded,
      ];
}