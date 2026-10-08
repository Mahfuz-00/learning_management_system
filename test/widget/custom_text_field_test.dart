// Widget tests for the shared input widgets.
//
// Covers CustomTextField rendering, password obscuring, validation display, and
// the LoginForm's submit behaviour (validation blocks the request; a valid form
// dispatches LoginRequested to the AuthBloc).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/auth_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/auth_state.dart';
import 'package:lms_touch_and_solve/Presentation/Auth/Widgets/login_widgets.dart';
import 'package:lms_touch_and_solve/Presentation/Shared%20Widgets/custom_text_field.dart';

import '../helpers/fakes.dart';
import '../helpers/test_harness.dart';

void main() {
  group('CustomTextField', () {
    testWidgets('renders its label and hint', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          CustomTextField(
            controller: TextEditingController(),
            labelText: 'Email Address',
            hintText: 'Enter your email',
          ),
        ),
      );

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('obscures the text when isPassword is true', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          CustomTextField(
            controller: TextEditingController(),
            labelText: 'Password',
            hintText: 'Enter password',
            isPassword: true,
          ),
        ),
      );

      // TextFormField has no public obscureText getter; the flag lives on the
      // TextField it builds.
      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField),
          matching: find.byType(TextField),
        ),
      );
      expect(field.obscureText, isTrue);
    });

    testWidgets('renders a prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          CustomTextField(
            controller: TextEditingController(),
            labelText: 'Email',
            hintText: 'you@example.com',
            prefixIcon: Icons.email_outlined,
          ),
        ),
      );

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('accepts typed text into its controller', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrapWithApp(
          CustomTextField(
            controller: controller,
            labelText: 'Email',
            hintText: 'Enter your email',
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'student@nirvoor.com');
      await tester.pump();

      expect(controller.text, 'student@nirvoor.com');
    });

    testWidgets('shows its validation error after an invalid submit',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        wrapWithApp(
          Form(
            key: formKey,
            child: CustomTextField(
              controller: TextEditingController(),
              labelText: 'Email',
              hintText: 'you@example.com',
              validator: (v) => (v == null || v.isEmpty) ? 'Enter your email' : null,
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Enter your email'), findsOneWidget);
    });
  });

  group('LoginForm', () {
    Widget host(AuthBloc bloc) => MaterialApp(
          theme: testTheme(),
          home: Scaffold(
            body: BlocProvider<AuthBloc>.value(
              value: bloc,
              child: const LoginForm(),
            ),
          ),
        );

    testWidgets('renders email, password and the login button', (tester) async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());
      addTearDown(bloc.close);

      await tester.pumpWidget(host(bloc));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('an empty submit blocks the request and shows both errors',
        (tester) async {
      final repo = FakeAuthRepository();
      final bloc = AuthBloc(authRepository: repo);
      addTearDown(bloc.close);

      await tester.pumpWidget(host(bloc));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Enter email'), findsOneWidget);
      expect(find.text('Enter password'), findsOneWidget);
      // Validation failed, so the bloc must never have been asked to log in.
      expect(repo.loginCalls, isEmpty);
    });

    testWidgets('a filled form dispatches LoginRequested', (tester) async {
      final repo = FakeAuthRepository();
      final bloc = AuthBloc(authRepository: repo);
      addTearDown(bloc.close);

      await tester.pumpWidget(host(bloc));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'student@nirvoor.com');
      await tester.enterText(fields.at(1), 'secret123');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(repo.loginCalls, ['student@nirvoor.com:secret123']);
    });

    testWidgets('shows a spinner while the bloc is loading', (tester) async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());
      addTearDown(bloc.close);

      await tester.pumpWidget(host(bloc));

      // Drive the bloc into AuthLoading without a real request.
      bloc.emit(AuthLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsNothing);
    });
  });
}
