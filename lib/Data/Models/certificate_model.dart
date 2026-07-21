import '../../Domain/Entities/certificate_entity.dart';

class CertificateModel extends CertificateEntity {
  const CertificateModel({
    required super.id,
    required super.courseId,
    required super.courseTitle,
    required super.studentName,
    required super.issuedAt,
    super.certificateUrl,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      courseTitle: json['courseTitle'] ?? '',
      studentName: json['studentName'] ?? '',
      issuedAt: DateTime.parse(json['issuedAt'] ?? DateTime.now().toIso8601String()),
      certificateUrl: json['certificateUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'studentName': studentName,
      'issuedAt': issuedAt.toIso8601String(),
      'certificateUrl': certificateUrl,
    };
  }
}
