import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../Core/Theme/app_colors.dart';
import '../../../Domain/Entities/refund_entity.dart';
import '../Bloc/refund_bloc.dart';
import '../Bloc/refund_event.dart';
import '../Bloc/refund_state.dart';

/// Request a refund for a course, and track existing requests.
///
/// **Rule 9 (User Manual)** is stated plainly to the student because it is
/// surprising: *"When admin approves a refund, the enrolment is **deleted**,
/// not marked as cancelled. The student loses access immediately."* and *"the
/// system **records** the refund. It does not move any money. Someone must send
/// the money back by hand."*
class RefundPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const RefundPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RefundBloc>().add(LoadRefundEligibility(widget.courseId));
    context.read<RefundBloc>().add(const LoadMyRefunds());
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    final reason = _reasonController.text.trim();
    if (reason.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your reason (at least 10 characters).'),
        ),
      );
      return;
    }
    context.read<RefundBloc>().add(
          RequestRefund(courseId: widget.courseId, reason: reason),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RefundBloc, RefundState>(
      listener: (context, state) {
        if (state.actionSucceeded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your request has been sent to the admin queue.'),
              backgroundColor: AppColors.secondaryGreen,
            ),
          );
          _reasonController.clear();
          context.read<RefundBloc>().add(const ClearRefundFeedback());
          context.read<RefundBloc>().add(const LoadMyRefunds());
        }
        if (state.errorMessage != null &&
            state.status == RefundLoadStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Refund Request')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRule9Warning(),
                const SizedBox(height: 16),
                _buildEligibility(state),
                const SizedBox(height: 16),
                if (state.canRequestRefund) _buildRequestForm(state),
                const SizedBox(height: 20),
                _buildMyRequests(state),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// States Rule 9's consequences before the student commits.
  Widget _buildRule9Warning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              Text(
                'Before you request a refund',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• If the admin approves your refund, your enrollment is deleted '
            'and you lose access to this course immediately.\n'
            '• The system only records the refund. The money is sent back to '
            'you manually, outside the app.\n'
            '• An approved refund can be undone only by the admin.',
            style: TextStyle(fontSize: 12.5, color: Colors.orange.shade900),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibility(RefundState state) {
    if (state.status == RefundLoadStatus.loading && state.eligibility == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final eligibility = state.eligibility;
    if (eligibility == null) return const SizedBox.shrink();

    final eligible = eligibility.isEligible;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              eligible ? Icons.check_circle : Icons.info_outline,
              color: eligible ? AppColors.secondaryGreen : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eligible
                        ? 'You are eligible for a refund'
                        : 'Refund not available',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (eligibility.reason != null)
                    Text(
                      eligibility.reason!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  if (eligibility.refundableAmount != null)
                    Text(
                      'Refundable amount: ৳${eligibility.refundableAmount!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestForm(RefundState state) {
    final submitting = state.status == RefundLoadStatus.submitting;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why do you want a refund?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              enabled: !submitting,
              decoration: const InputDecoration(
                hintText: 'Tell us what happened…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                onPressed: submitting ? null : _submitRequest,
                label: Text(submitting ? 'Sending…' : 'Submit refund request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRequests(RefundState state) {
    if (state.refunds.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your refund requests',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...state.refunds.map(_requestCard),
      ],
    );
  }

  Widget _requestCard(RefundEntity refund) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    refund.courseTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _statusChip(refund.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(refund.reason, style: const TextStyle(fontSize: 12.5)),
            if (refund.requestedAt != null) ...[
              const SizedBox(height: 6),
              Text(
                'Requested ${DateFormat('dd MMM yyyy').format(refund.requestedAt!)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
            if (refund.adminNote != null && refund.adminNote!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Admin: ${refund.adminNote}',
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
            if (refund.isCancellable) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context
                      .read<RefundBloc>()
                      .add(CancelRefund(refund.id)),
                  child: const Text('Withdraw request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(RefundStatus status) {
    late final Color color;
    late final String label;

    switch (status) {
      case RefundStatus.requested:
        color = Colors.orange;
        label = 'PENDING';
      case RefundStatus.approved:
        color = AppColors.errorRed;
        label = 'APPROVED';
      case RefundStatus.rejected:
        color = Colors.grey;
        label = 'REJECTED';
      case RefundStatus.reversed:
        color = AppColors.secondaryGreen;
        label = 'REVERSED (restored)';
      case RefundStatus.cancelled:
        color = Colors.grey;
        label = 'WITHDRAWN';
      case RefundStatus.none:
        color = Colors.grey;
        label = 'NONE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}