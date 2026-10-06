import 'dart:io';

import 'package:equatable/equatable.dart';

/// Base class for every event handled by `LearningBloc`.
abstract class LearningEvent extends Equatable {
  const LearningEvent();

  @override
  List<Object?> get props => [];
}

// ── Course hub loading ──────────────────────────────────────────────────

/// Loads everything the enrolled-course hub needs for one course.
///
/// Manual §4.3: the hub has five cards (Practice, Live Class, Recordings,
/// Exam, Suggestion) plus lessons and progress. One event loads them together
/// so the screen has a single loading state instead of five.
class LoadCourseHub extends LearningEvent {
  final String courseId;
  const LoadCourseHub(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

// ── Course exams (Manual §4.4) ──────────────────────────────────────────

/// Loads the four exam slots for a course.
class LoadCourseExams extends LearningEvent {
  final String courseId;
  const LoadCourseExams(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

/// Downloads the question paper metadata for an open exam.
class LoadExamQuestion extends LearningEvent {
  final String examId;
  const LoadExamQuestion(this.examId);

  @override
  List<Object?> get props => [examId];
}

/// Uploads the student's handwritten answer file before the deadline.
class SubmitExamAnswer extends LearningEvent {
  final String examId;
  final File file;
  const SubmitExamAnswer({required this.examId, required this.file});

  @override
  List<Object?> get props => [examId, file];
}

// ── Teacher: exam management ────────────────────────────────────────────

/// Creates an exam slot for a course (teacher only).
class CreateExamRequested extends LearningEvent {
  final Map<String, dynamic> data;
  const CreateExamRequested(this.data);

  @override
  List<Object?> get props => [data];
}

/// Uploads the question paper. **This is what opens the exam** for students.
class UploadExamQuestionRequested extends LearningEvent {
  final String examId;
  final File file;
  const UploadExamQuestionRequested({required this.examId, required this.file});

  @override
  List<Object?> get props => [examId, file];
}

/// Loads the submissions queue for a teacher to mark.
class LoadExamSubmissions extends LearningEvent {
  final String examId;
  const LoadExamSubmissions(this.examId);

  @override
  List<Object?> get props => [examId];
}

/// Records a mark and feedback for one student submission.
class GradeExamSubmissionRequested extends LearningEvent {
  final String submissionId;
  final int marks;
  final String? feedback;
  const GradeExamSubmissionRequested({
    required this.submissionId,
    required this.marks,
    this.feedback,
  });

  @override
  List<Object?> get props => [submissionId, marks, feedback];
}

// ── Live-class exams (Manual §4.4 / §5.2) ───────────────────────────────

/// Loads the live exam attached to a live class.
class LoadLiveExam extends LearningEvent {
  final String liveClassId;
  const LoadLiveExam(this.liveClassId);

  @override
  List<Object?> get props => [liveClassId];
}

/// Loads a live exam for the **teacher's** management view.
class LoadLiveExamManage extends LearningEvent {
  final String liveClassId;
  const LoadLiveExamManage(this.liveClassId);

  @override
  List<Object?> get props => [liveClassId];
}

/// Saves the whole question set built in the live-exam editor (teacher only).
class SaveLiveExamRequested extends LearningEvent {
  final String liveClassId;
  final Map<String, dynamic> data;
  const SaveLiveExamRequested({required this.liveClassId, required this.data});

  @override
  List<Object?> get props => [liveClassId, data];
}

/// Releases a live exam to students.
class PublishLiveExamRequested extends LearningEvent {
  final String examId;
  const PublishLiveExamRequested(this.examId);

  @override
  List<Object?> get props => [examId];
}

/// Opens a live exam for a student to sit.
class TakeLiveExamRequested extends LearningEvent {
  final String examId;
  const TakeLiveExamRequested(this.examId);

  @override
  List<Object?> get props => [examId];
}

/// Submits a student's live-exam answers.
class SubmitLiveExamRequested extends LearningEvent {
  final String examId;
  final Map<String, dynamic> answers;
  const SubmitLiveExamRequested({required this.examId, required this.answers});

  @override
  List<Object?> get props => [examId, answers];
}

/// Loads live-exam responses for marking.
class LoadLiveExamSubmissions extends LearningEvent {
  final String examId;
  const LoadLiveExamSubmissions(this.examId);

  @override
  List<Object?> get props => [examId];
}

/// Records a mark on a live-exam submission.
class GradeLiveExamRequested extends LearningEvent {
  final String submissionId;
  final double marks;
  final String? feedback;
  const GradeLiveExamRequested({
    required this.submissionId,
    required this.marks,
    this.feedback,
  });

  @override
  List<Object?> get props => [submissionId, marks, feedback];
}

// ── AI writing (Manual §4.4) ────────────────────────────────────────────

/// Loads all AI writing tasks for a course.
class LoadAiWritingTasks extends LearningEvent {
  final String courseId;
  const LoadAiWritingTasks(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

/// Loads a single AI writing task plus the student's attempt history.
class LoadAiWritingTask extends LearningEvent {
  final String taskId;
  const LoadAiWritingTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Uploads a handwritten answer photo for AI marking.
/// Multiple attempts are allowed — the last one counts.
class SubmitAiWritingRequested extends LearningEvent {
  final String taskId;
  final File photo;
  const SubmitAiWritingRequested({required this.taskId, required this.photo});

  @override
  List<Object?> get props => [taskId, photo];
}

// ── Practice & suggestions ──────────────────────────────────────────────

/// Loads the practice files and exam suggestions for a course.
class LoadPracticeFiles extends LearningEvent {
  final String courseId;
  const LoadPracticeFiles(this.courseId);

  @override
  List<Object?> get props => [courseId];
}