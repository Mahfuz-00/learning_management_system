import 'package:equatable/equatable.dart';

class CertificateEntity extends Equatable {
  final String id;
  final String courseId;
  final String courseTitle;
  final String studentName;
  final DateTime issuedAt;
  final String? certificateUrl;

  const CertificateEntity({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.studentName,
    required this.issuedAt,
    this.certificateUrl,
  });

  @override
  List<Object?> get props => [id, courseId, courseTitle, studentName, issuedAt, certificateUrl];
}
