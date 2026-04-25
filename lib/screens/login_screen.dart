import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import 'inventory_screen.dart';
import 'password_recovery_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final IAuthService _authService = AuthConfig.createService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe usuario e senha.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(username, password);

      if (!mounted) {
        return;
      }

      final accessToken =
          result['access_token'] ?? result['accessToken'] ?? result['token'];
      debugPrint('Token recebido: $accessToken');
      Navigator.pushReplacementNamed(context, InventoryScreen.routeName);
    } catch (error) {
      if (!mounted) {
        return;
      }

      final errorMessage = error.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width >= 700;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen ? 920 : 460,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 28,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: isLargeScreen
                        ? Row(
                            children: [
                              Expanded(child: _buildHeroContent(context)),
                              const SizedBox(width: 32),
                              Expanded(child: _buildLoginCard(context)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeroContent(context),
                              const SizedBox(height: 24),
                              _buildLoginCard(context),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.asset(
            'assets/images/logo_placeholder.png',
            height: 92,
            width: 92,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'NextInventory',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Controle seus ativos de forma simples e eficiente, com uma interface intuitiva e recursos poderosos.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Entrar',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _emailController,
            label: 'Usuario',
            hintText: 'emilys',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: 'Senha',
            hintText: 'emilyspass',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Text('Entrar'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, PasswordRecoveryScreen.routeName);
            },
            child: const Text('Recuperar senha'),
          ),
        ],
      ),
    );
  }
}
