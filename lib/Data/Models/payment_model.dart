import '../../Domain/Entities/payment_entity.dart';
import 'json_utils.dart';

/// JSON mapping for the server's authoritative checkout quote.
///
/// **Rule 4 is enforced here.** The client does not decide which discount wins;
/// it simply renders what this model contains. The server compares campaign,
/// coupon and corporate offers in Taka and marks exactly one as applied.
class PaymentQuoteModel extends PaymentQuoteEntity {
  const PaymentQuoteModel({
    required super.originalPrice,
    super.appliedDiscount,
    super.losingOffers,
    required super.payableAmount,
    super.isFullyDiscounted,
  });

  factory PaymentQuoteModel.fromJson(Map<String, dynamic> json) {
    // The API may return discounts either as a flat list with an `isApplied`
    // flag, or as separate `appliedDiscount` + `otherDiscounts` objects. Both
    // shapes are normalised into one list here.
    final List<DiscountOfferEntity> offers = [];

    final appliedRaw = json['appliedDiscount'];
    if (appliedRaw is Map) {
      offers.add(_offerFromJson(
        Map<String, dynamic>.from(appliedRaw),
        forceApplied: true,
      ));
    }

    final listRaw = json['discounts'] ?? json['offers'] ?? json['losingOffers'];
    if (listRaw is List) {
      for (final item in listRaw.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        // Skip a duplicate of the applied offer if the server sent both.
        final isApplied = JsonUtils.toBool(map['isApplied']);
        if (isApplied && offers.any((o) => o.isApplied)) continue;
        offers.add(_offerFromJson(map, forceApplied: isApplied));
      }
    }

    // Ensure the applied offer is first so the UI renders it at the top.
    offers.sort((a, b) => (b.isApplied ? 1 : 0).compareTo(a.isApplied ? 1 : 0));

    final applied = offers.where((o) => o.isApplied).firstOrNull;
    final losing = offers.where((o) => !o.isApplied).toList();

    final original = JsonUtils.toDouble(
      json['originalPrice'] ?? json['price'] ?? json['basePrice'],
    );
    final payable = JsonUtils.toDouble(
      json['payableAmount'] ?? json['finalPrice'] ?? json['amount'],
      fallback: original,
    );

    return PaymentQuoteModel(
      originalPrice: original,
      appliedDiscount: applied,
      losingOffers: losing,
      payableAmount: payable,
      isFullyDiscounted: JsonUtils.toBool(
        json['isFullyDiscounted'],
        fallback: payable <= 0,
      ),
    );
  }

  /// Builds a single offer, tolerating several field-name variants.
  static DiscountOfferEntity _offerFromJson(
    Map<String, dynamic> json, {
    required bool forceApplied,
  }) {
    final amount = JsonUtils.toDouble(
      json['amountInTaka'] ??
          json['discountAmount'] ??
          json['savings'] ??
          json['amount'],
    );
    final percent = JsonUtils.toDoubleOrNull(
      json['percent'] ?? json['discountPercent'],
    );

    return DiscountOfferEntity(
      source: DiscountSource.fromString(
        json['source']?.toString() ?? json['type']?.toString(),
      ),
      label: JsonUtils.toStringValue(
        json['label'] ?? json['code'] ?? json['companyName'] ?? json['name'],
        fallback: 'Discount',
      ),
      amountInTaka: amount,
      isApplied: forceApplied || JsonUtils.toBool(json['isApplied']),
      percent: percent,
      notAppliedReason: JsonUtils.toStringOrNull(json['notAppliedReason']),
    );
  }
}

/// JSON mapping for the result of initiating a payment.
class PaymentInitiationModel extends PaymentInitiationEntity {
  const PaymentInitiationModel({
    required super.transactionId,
    super.status,
    super.gatewayUrl,
    super.successUrl,
    super.failUrl,
    super.cancelUrl,
    super.amount,
    super.message,
  });

  factory PaymentInitiationModel.fromJson(Map<String, dynamic> json) {
    return PaymentInitiationModel(
      transactionId: JsonUtils.toStringValue(
        json['transactionId'] ?? json['id'],
      ),
      status: PaymentStatus.fromString(json['status']?.toString()),
      gatewayUrl: JsonUtils.toStringOrNull(
        json['gatewayUrl'] ?? json['redirectUrl'] ?? json['paymentUrl'],
      ),
      successUrl: JsonUtils.toStringOrNull(json['successUrl']),
      failUrl: JsonUtils.toStringOrNull(json['failUrl']),
      cancelUrl: JsonUtils.toStringOrNull(json['cancelUrl']),
      amount: JsonUtils.toDoubleOrNull(json['amount']),
      message: JsonUtils.toStringOrNull(json['message']),
    );
  }
}

/// JSON mapping for a company discount available at checkout.
class CorporateCouponModel extends CorporateCouponEntity {
  const CorporateCouponModel({
    required super.id,
    required super.companyName,
    super.logoUrl,
    super.percent,
    super.amount,
  });

  factory CorporateCouponModel.fromJson(Map<String, dynamic> json) {
    return CorporateCouponModel(
      id: JsonUtils.toStringValue(json['id']),
      companyName: JsonUtils.toStringValue(
        json['companyName'] ?? json['name'],
        fallback: 'Company',
      ),
      logoUrl: JsonUtils.toStringOrNull(json['logoUrl'] ?? json['logoPath']),
      percent: JsonUtils.toDoubleOrNull(json['percent'] ?? json['discountPercent']),
      amount: JsonUtils.toDoubleOrNull(json['amount'] ?? json['discountAmount']),
    );
  }
}