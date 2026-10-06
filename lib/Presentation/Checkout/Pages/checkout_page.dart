import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/payment_entity.dart';
import '../Bloc/checkout_bloc.dart';
import '../Bloc/checkout_event.dart';
import '../Bloc/checkout_state.dart';

/// The checkout page (Manual §4.2).
///
/// *"Goes to checkout. Enter a coupon code if you have one, choose 'Pay via'
/// company if a corporate discount applies, then pay through SSLCommerz."*
///
/// **Rule 4 is the whole point of this screen.** The page renders whatever the
/// server's `POST /api/Payment/quote` returns, including the *losing* offers
/// greyed out and marked "not applied", because the manual says that is
/// deliberate: *"it shows the student the offer existed and why it was not
/// used."* The client never calculates a discount itself.
class CheckoutPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final double originalPrice;

  const CheckoutPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
    this.originalPrice = 0,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CheckoutBloc>().add(LoadCheckoutQuote(widget.courseId));
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        // Free / fully-discounted course: enrolled with no payment page.
        if (state.enrolledInstantly) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enrolled successfully! The course is now in My Courses.'),
              backgroundColor: AppColors.secondaryGreen,
            ),
          );
          context.read<CheckoutBloc>().add(const ClearCheckoutFeedback());
          context.go('/student');
          return;
        }

        if (state.errorMessage != null && state.status == CheckoutStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == CheckoutStatus.initial ||
            (state.status == CheckoutStatus.loading && state.quote == null)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final quote = state.quote;

        return Scaffold(
          appBar: AppBar(title: const Text('Checkout')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCourseHeader(),
                const SizedBox(height: 16),

                // Coupon entry — Rule 4 may make this lose to a bigger offer.
                _buildCouponField(state),

                const SizedBox(height: 16),

                // "Pay via" company selector (Manual §4.2).
                if (state.corporateCoupons.isNotEmpty)
                  _buildCorporateSelector(state),

                const SizedBox(height: 16),

                // The full price breakdown, including losing offers.
                if (quote != null) _buildPriceBreakdown(quote),

                const SizedBox(height: 24),
                _buildPayButton(state, quote),
                const SizedBox(height: 12),
                _buildRule4Note(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school_rounded, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.courseTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lifetime access',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponField(CheckoutState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Have a coupon code?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'Enter code',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 46),
                  ),
                  onPressed: state.status == CheckoutStatus.loading
                      ? null
                      : () {
                          final code = _couponController.text.trim();
                          if (code.isEmpty) return;
                          context.read<CheckoutBloc>().add(
                                ApplyCouponCode(
                                  courseId: widget.courseId,
                                  couponCode: code,
                                ),
                              );
                        },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The "Pay via" company dropdown (Manual §4.2).
  Widget _buildCorporateSelector(CheckoutState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pay via company',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'If your employer has a corporate discount, select it here.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String?>(
              initialValue: state.selectedCorporateCouponId,
              decoration: const InputDecoration(isDense: true),
              hint: const Text('No company discount'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No company discount'),
                ),
                ...state.corporateCoupons.map(
                  (coupon) => DropdownMenuItem<String?>(
                    value: coupon.id,
                    child: Text('${coupon.companyName} — ${coupon.description}'),
                  ),
                ),
              ],
              onChanged: state.status == CheckoutStatus.loading
                  ? null
                  : (value) => context.read<CheckoutBloc>().add(
                        SelectCorporateCoupon(
                          courseId: widget.courseId,
                          corporateCouponId: value,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  /// The price breakdown.
  ///
  /// Shows the original price, the **single** applied discount, every losing
  /// offer greyed out, and the final payable amount.
  Widget _buildPriceBreakdown(PaymentQuoteEntity quote) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _row('Course price', '৳${quote.originalPrice.toStringAsFixed(0)}'),

            const Divider(height: 20),

            // Rule 4: only ONE discount is ever applied.
            ...quote.allOffers.map(_buildOfferRow),

            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'You pay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '৳${quote.payableAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryGreen,
                  ),
                ),
              ],
            ),

            if (quote.totalSavings > 0) ...[
              const SizedBox(height: 6),
              Text(
                'You save ৳${quote.totalSavings.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Renders one discount offer — applied (green) or losing (greyed out).
  ///
  /// The losing row is intentionally still visible. **Rule 4:** *"At checkout
  /// you will see the losing corporate offer still listed, greyed out and
  /// marked as not applied. That is deliberate."*
  Widget _buildOfferRow(DiscountOfferEntity offer) {
    final applied = offer.isApplied;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Opacity(
        opacity: applied ? 1 : 0.45,
        child: Row(
          children: [
            Icon(
              applied ? Icons.check_circle : Icons.cancel_outlined,
              size: 17,
              color: applied ? AppColors.secondaryGreen : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${offer.source.label}: ${offer.label}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: applied ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (!applied)
                    Text(
                      offer.notAppliedReason ??
                          'Not applied — a bigger discount was used instead',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Text(
              '-৳${offer.amountInTaka.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: applied ? AppColors.secondaryGreen : Colors.grey,
                decoration: applied ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPayButton(CheckoutState state, PaymentQuoteEntity? quote) {
    final busy = state.status == CheckoutStatus.processing ||
        state.status == CheckoutStatus.redirecting;

    // Manual §4.2: a free (or fully discounted) course enrolls immediately with
    // no payment page.
    final isFree = quote?.canEnrollWithoutPayment ?? false;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: busy
            ? null
            : () => context.read<CheckoutBloc>().add(
                  InitiateCheckoutPayment(courseId: widget.courseId),
                ),
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(isFree ? Icons.check_circle : Icons.payment),
        label: Text(
          busy
              ? 'Please wait…'
              : isFree
                  ? 'Enroll Now (Free)'
                  : 'Pay ৳${(quote?.payableAmount ?? 0).toStringAsFixed(0)}',
        ),
      ),
    );
  }

  /// Explains Rule 4 to the student so the greyed-out row is not reported as a
  /// bug — exactly the kind of confusion the User Manual warns about.
  Widget _buildRule4Note() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Discounts never add up. Only the single biggest saving is '
              'applied — any other offer is shown greyed out so you can see '
              'it existed and why it was not used.',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
            ),
          ),
        ],
      ),
    );
  }
}