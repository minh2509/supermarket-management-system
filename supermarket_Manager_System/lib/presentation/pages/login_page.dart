import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_manager_system/data/services/auth_api_service.dart';
import 'package:supermarket_manager_system/presentation/theme/app_theme.dart';
import 'package:supermarket_manager_system/utils/app_session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApiService = AuthApiService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email/username and password'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _authApiService.login(
        emailOrUsername: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      final roleName = result.role.toLowerCase();
      AppSession.instance.setLogin(
        userId: result.userId,
        roleId: result.roleId,
        fullName: result.fullName,
        role: result.role,
      );
      if (result.roleId == 3 || roleName.contains('cashier')) {
        context.go('/cashier/open-shift');
      } else if (roleName.contains('admin')) {
        context.go('/admin/dashboard');
      } else if (roleName.contains('manager')) {
        context.go('/manager/dashboard');
      } else {
        context.go('/role-home');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showBrandPanel = constraints.maxWidth >= 900;
          return Stack(
            children: [
              const Positioned.fill(child: _LoginBackground()),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth < 600 ? 20 : 40,
                      vertical: 28,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1060),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A173D2B),
                              blurRadius: 48,
                              offset: Offset(0, 20),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Row(
                          children: [
                            if (showBrandPanel)
                              const Expanded(child: _BrandPanel()),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(
                                  constraints.maxWidth < 600 ? 24 : 48,
                                ),
                                child: _buildLoginForm(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return AutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CompactBrand(),
          const SizedBox(height: 32),
          Text(
            'Welcome back',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue to SuperMart.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 32),
          const _FieldLabel('Email or username'),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _emailController,
            hintText: 'name@supermart.com',
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            maxLength: 50,
            prefixIcon: const Icon(Icons.person_outline_rounded),
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: _FieldLabel('Password')),
              TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: const Text('Forgot password?'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _AppTextField(
            controller: _passwordController,
            hintText: 'Enter your password',
            keyboardType: TextInputType.visiblePassword,
            obscureText: !_isPasswordVisible,
            maxLength: 50,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) {
              if (!_isLoading) _onLoginPressed();
            },
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _onLoginPressed,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.arrow_forward_rounded),
            label: Text(_isLoading ? 'Signing in...' : 'Sign in'),
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 16, color: AppColors.muted),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Secure access for authorized staff',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    required this.obscureText,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLength,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
}

class _CompactBrand extends StatelessWidget {
  const _CompactBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.local_grocery_store_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SuperMart',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            Text(
              'Smart retail system',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 650),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/market.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xD90A2F20), Color(0xB30C5735)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(52),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CompactBrandOnDark(),
              SizedBox(height: 150),
              Icon(Icons.insights_rounded, size: 54, color: Color(0xFFFFC06A)),
              SizedBox(height: 24),
              Text(
                'Everything your store needs, in one place.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Fast checkout on mobile. Clear operations and reports on the web.',
                style: TextStyle(
                  color: Color(0xFFD8F1E3),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 42),
              _BrandFeature(
                icon: Icons.qr_code_scanner_rounded,
                text: 'Quick mobile checkout',
              ),
              SizedBox(height: 14),
              _BrandFeature(
                icon: Icons.dashboard_customize_outlined,
                text: 'Responsive management dashboard',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactBrandOnDark extends StatelessWidget {
  const _CompactBrandOnDark();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.local_grocery_store_rounded, color: Colors.white, size: 30),
        SizedBox(width: 10),
        Text(
          'SuperMart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _BrandFeature extends StatelessWidget {
  const _BrandFeature({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC06A), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0F8F3), Color(0xFFF8F4EC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(painter: _LoginPatternPainter()),
    );
  }
}

class _LoginPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withValues(alpha: 0.045);
    for (double y = 30; y < size.height; y += 64) {
      for (double x = 24; x < size.width; x += 64) {
        canvas.drawCircle(Offset(x + (y % 128 == 0 ? 20 : 0), y), 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
