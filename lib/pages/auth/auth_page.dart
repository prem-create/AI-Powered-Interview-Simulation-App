import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:interview_app/pages/auth/bloc/auth_bloc.dart';

enum AuthView { login, createAccount, forgotPassword }

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: const _AuthViewSwitcher(),
    );
  }
}

class _AuthViewSwitcher extends StatefulWidget {
  const _AuthViewSwitcher();

  @override
  State<_AuthViewSwitcher> createState() => _AuthViewSwitcherState();
}

class _AuthViewSwitcherState extends State<_AuthViewSwitcher> {
  AuthView _currentView = AuthView.login;

  void _showView(AuthView view) {
    setState(() {
      _currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: switch (_currentView) {
                AuthView.login => _LoginView(onShowView: _showView),
                AuthView.createAccount => _CreateAccountView(
                  onShowView: _showView,
                ),
                AuthView.forgotPassword => _ForgotPasswordView(
                  onShowView: _showView,
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({required this.onShowView});

  final ValueChanged<AuthView> onShowView;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    context.read<AuthBloc>().add(
      LoginSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state case AuthSuccess(action: AuthSuccessAction.navigateHome)) {
          context.go('/home');
        }

        if (state case AuthFailure(:final message)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _formKey,
          child: _AuthForm(
            title: 'Login',
            children: [
              _EmailField(controller: _emailController),
              const SizedBox(height: 12),
              _PasswordField(
                controller: _passwordController,
                autofillHints: const [AutofillHints.password],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: Text(isLoading ? 'Logging in...' : 'Login'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () =>
                          context.read<AuthBloc>().add(GoogleLoginSubmitted()),
                child: const Text('Login with Google'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => widget.onShowView(AuthView.forgotPassword),
                child: const Text('Forgot password?'),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => widget.onShowView(AuthView.createAccount),
                child: const Text('Create new account'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CreateAccountView extends StatefulWidget {
  const _CreateAccountView({required this.onShowView});

  final ValueChanged<AuthView> onShowView;

  @override
  State<_CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<_CreateAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    context.read<AuthBloc>().add(
      CreateAccountSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state case AuthSuccess(
          :final message,
          action: AuthSuccessAction.showMessageAndLogin,
        )) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          _emailController.clear();
          _passwordController.clear();
          widget.onShowView(AuthView.login);
        }

        if (state case AuthSuccess(action: AuthSuccessAction.navigateHome)) {
          context.go('/home');
        }

        if (state case AuthFailure(:final message)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _formKey,
          child: _AuthForm(
            title: 'Create new account',
            children: [
              _EmailField(controller: _emailController),
              const SizedBox(height: 12),
              _PasswordField(
                controller: _passwordController,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: Text(
                  isLoading ? 'Creating account...' : 'Create account',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () =>
                          context.read<AuthBloc>().add(GoogleLoginSubmitted()),
                child: const Text('Login with Google'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => widget.onShowView(AuthView.login),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView({required this.onShowView});

  final ValueChanged<AuthView> onShowView;

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    context.read<AuthBloc>().add(
      ForgotPasswordSubmitted(email: _emailController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state case AuthSuccess(
          :final message,
          action: AuthSuccessAction.showMessageAndLoginAfterPasswordReset,
        )) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          _emailController.clear();
          widget.onShowView(AuthView.login);
        }

        if (state case AuthFailure(:final message)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _formKey,
          child: _AuthForm(
            title: 'Forgot password',
            children: [
              _EmailField(controller: _emailController),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: Text(
                  isLoading ? 'Sending reset link...' : 'Send reset link',
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => widget.onShowView(AuthView.login),
                child: const Text('Back to login'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({this.controller});

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
      validator: _validateEmail,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({this.controller, this.autofillHints});

  final TextEditingController? controller;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      autofillHints: autofillHints,
      textInputAction: TextInputAction.done,
      validator: _validatePassword,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
    );
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }
}
