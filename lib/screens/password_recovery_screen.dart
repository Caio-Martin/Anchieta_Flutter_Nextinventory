import 'package:flutter/material.dart';
import 'login_screen.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  static const routeName = '/password-recovery';

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isLoadingVerification = false;
  bool _isLoadingReset = false;

  @override
  void dispose() {
    _emailController.dispose();
    _verificationCodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoadingVerification = true);

    // Simular delay de envio
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoadingVerification = false;
      _currentStep = 1;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Código de verificação enviado para ${_emailController.text}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoadingReset = true);
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoadingReset = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha alterada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
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
                    maxWidth: isLargeScreen ? 500 : 460,
                  ),
                  child: Form(
                    key: _formKey,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Cabeçalho com ícone e título
                          Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2F1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.lock_reset,
                                size: 32,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Recuperar Senha',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentStep == 0
                                ? 'Digite seu e-mail para receber um código de verificação'
                                : 'Insira o código e defina uma nova senha',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),

                          // Stepper visual
                          _buildStepIndicator(),
                          const SizedBox(height: 28),

                          // Conteúdo dinâmico
                          if (_currentStep == 0)
                            ..._buildStep1()
                          else
                            ..._buildStep2(),

                          const SizedBox(height: 24),

                          // Botões
                          SizedBox(
                            height: 54,
                            child: FilledButton(
                              onPressed: _currentStep == 0
                                  ? _isLoadingVerification
                                        ? null
                                        : _sendVerificationCode
                                  : _isLoadingReset
                                  ? null
                                  : _resetPassword,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: _currentStep == 0
                                  ? _isLoadingVerification
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text('Enviar Código')
                                  : _isLoadingReset
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text('ALTERAR SENHA'),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Voltar ao login
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Voltar ao login'),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(0, '1', 'E-mail'),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: _currentStep >= 1
                ? const Color(0xFF135D66)
                : Colors.grey[300],
          ),
        ),
        _buildStepCircle(1, '2', 'Nova Senha'),
      ],
    );
  }

  Widget _buildStepCircle(int step, String number, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF135D66) : Colors.grey[300],
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            color: isCurrent
                ? const Color(0xFF135D66)
                : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStep1() {
    return [
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'E-mail',
          hintText: 'seu.email@edu.anchieta.br',
          prefixIcon: const Icon(Icons.email_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'E-mail é obrigatório';
          }
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Insira um e-mail válido';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF92400E), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Um código será enviado para seu e-mail',
                style: TextStyle(color: const Color(0xFF92400E), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildStep2() {
    return [
      TextFormField(
        controller: _verificationCodeController,
        decoration: InputDecoration(
          labelText: 'Código de Verificação',
          hintText: '000000',
          prefixIcon: const Icon(Icons.pin_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: TextInputType.number,
        maxLength: 6,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Código de verificação é obrigatório';
          }
          if (value.length != 6) {
            return 'Código deve ter 6 dígitos';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _newPasswordController,
        decoration: InputDecoration(
          labelText: 'Nova Senha',
          hintText: '••••••••',
          prefixIcon: const Icon(Icons.lock_outline),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Nova senha é obrigatória';
          }
          if (value.length < 8) {
            return 'Senha deve ter no mínimo 8 caracteres';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _confirmPasswordController,
        decoration: InputDecoration(
          labelText: 'Confirmar Senha',
          hintText: '••••••••',
          prefixIcon: const Icon(Icons.lock_outline),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Confirmação de senha é obrigatória';
          }
          if (value != _newPasswordController.text) {
            return 'As senhas não correspondem';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF065F46),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Mínimo 8 caracteres',
                style: TextStyle(color: const Color(0xFF065F46), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
