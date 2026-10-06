import 'package:equatable/equatable.dart';

/// Where a discount came from.
enum DiscountSource {
  /// A site-wide campaign discount set on the course itself.
  campaign,

  /// A coupon code the student typed at checkout.
  coupon,

  /// A company-wide discount with no code, chosen under "Pay via".
  corporate;

  /// Human label shown on the checkout summary.
  String get label {
    switch (this) {
      case DiscountSource.campaign:
        return 'Campaign discount';
      case DiscountSource.coupon:
        return 'Coupon code';
      case DiscountSource.corporate:
        return 'Company discount';
    }
  }

  static DiscountSource fromString(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'coupon':
        return DiscountSource.coupon;
      case 'corporate':
      case 'company':
        return DiscountSource.corporate;
      default:
        return DiscountSource.campaign;
    }
  }
}

/// One discount offer competing at checkout.
///
/// **Rule 4 (User Manual)** — *"A course can have a campaign discount, a coupon
/// code, and a company (corporate) discount all at once. They do **not** stack.
/// The system compares them in taka and applies only the **single largest**
/// saving."*
///
/// So every offer carries an [isApplied] flag. The losing offers are still
/// rendered — greyed out and marked "not applied" — because the manual says
/// *"That is deliberate — it shows the student the offer existed and why it was
/// not used."*
class DiscountOfferEntity extends Equatable {
  final DiscountSource source;

  /// A human label, e.g. the coupon code "EID2026" or the company name.
  final String label;

  /// The saving this offer represents, **in Taka**. Comparisons are always
  /// made on this absolute amount, never on the percentage, because a 10% offer
  /// can beat a 20% offer when the percentages apply to different bases.
  final double amountInTaka;

  /// True only for the single winning offer.
  final bool isApplied;

  /// Percentage, when the offer was defined as a percentage. Display only.
  final double? percent;

  /// A short explanation shown next to a losing offer, e.g.
  /// "Not applied — a bigger coupon discount was used instead."
  final String? notAppliedReason;

  const DiscountOfferEntity({
    required this.source,
    required this.label,
    required this.amountInTaka,
    this.isApplied = false,
    this.percent,
    this.notAppliedReason,
  });

  @override
  List<Object?> get props =>
      [source, label, amountInTaka, isApplied, percent, notAppliedReason];
}

/// The server's authoritative price calculation for a course purchase.
///
/// **The client must never compute discounts itself.** `POST /api/Payment/quote`
/// is the single source of truth, because Rule 4's "largest one wins" logic
/// lives on the server and depends on data the client does not have (corporate
/// eligibility, campaign windows, prior coupon usage).
class PaymentQuoteEntity extends Equatable {
  /// Full price before any discount, in Taka.
  final double originalPrice;

  /// The single winning offer, or null when nothing applies.
  final DiscountOfferEntity? appliedDiscount;

  /// Offers that lost the Rule 4 comparison. Rendered greyed out.
  final List<DiscountOfferEntity> losingOffers;

  /// What the student actually pays.
  final double payableAmount;

  /// True when [payableAmount] is zero.
  ///
  /// Manual §4.2: *"If the price is zero, or a discount covers the full price,
  /// you are enrolled immediately with no payment page."*
  final bool isFullyDiscounted;

  const PaymentQuoteEntity({
    required this.originalPrice,
    this.appliedDiscount,
    this.losingOffers = const [],
    required this.payableAmount,
    this.isFullyDiscounted = false,
  });

  /// Total money saved, in Taka.
  double get totalSavings => originalPrice - payableAmount;

  /// All offers (winning first) for a single rendered list.
  List<DiscountOfferEntity> get allOffers => [
        if (appliedDiscount != null) appliedDiscount!,
        ...losingOffers,
      ];

  /// True when the student can skip the SSLCommerz page entirely.
  bool get canEnrollWithoutPayment => isFullyDiscounted || payableAmount <= 0;

  @override
  List<Object?> get props => [
        originalPrice,
        appliedDiscount,
        losingOffers,
        payableAmount,
        isFullyDiscounted,
      ];
}

/// Status of an SSLCommerz transaction.
enum PaymentStatus {
  pending,
  success,
  failed,
  cancelled,

  /// Payment succeeded but the enrollment is being held (fraud review).
  held;

  static PaymentStatus fromString(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'success':
      case 'succeeded':
      case 'valid':
        return PaymentStatus.success;
      case 'failed':
      case 'fail':
        return PaymentStatus.failed;
      case 'cancelled':
      case 'canceled':
        return PaymentStatus.cancelled;
      case 'held':
        return PaymentStatus.held;
      default:
        return PaymentStatus.pending;
    }
  }
}

/// The result of initiating a payment.
class PaymentInitiationEntity extends Equatable {
  final String transactionId;
  final PaymentStatus status;

  /// The SSLCommerz-hosted checkout page the app must open in a WebView.
  final String? gatewayUrl;

  /// Where the gateway redirects on success / failure / cancellation.
  final String? successUrl;
  final String? failUrl;
  final String? cancelUrl;

  final double? amount;
  final String? message;

  const PaymentInitiationEntity({
    required this.transactionId,
    this.status = PaymentStatus.pending,
    this.gatewayUrl,
    this.successUrl,
    this.failUrl,
    this.cancelUrl,
    this.amount,
    this.message,
  });

  /// True when the course was granted without a gateway round-trip.
  bool get isInstantEnrollment => gatewayUrl == null || gatewayUrl!.isEmpty;

  @override
  List<Object?> get props => [
        transactionId,
        status,
        gatewayUrl,
        successUrl,
        failUrl,
        cancelUrl,
        amount,
        message,
      ];
}

/// A company discount the student can pick under "Pay via" at checkout.
class CorporateCouponEntity extends Equatable {
  final String id;
  final String companyName;
  final String? logoUrl;

  /// Percentage off, when the company discount is defined as a percentage.
  final double? percent;

  /// Flat amount off, in Taka, when defined as a fixed amount.
  final double? amount;

  const CorporateCouponEntity({
    required this.id,
    required this.companyName,
    this.logoUrl,
    this.percent,
    this.amount,
  });

  /// Short description for the dropdown row.
  String get description {
    if (percent != null) return '${percent!.toStringAsFixed(0)}% off';
    if (amount != null) return '৳${amount!.toStringAsFixed(0)} off';
    return 'Company discount';
  }

  @override
  List<Object?> get props => [id, companyName, logoUrl, percent, amount];
}