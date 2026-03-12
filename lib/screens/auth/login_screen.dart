import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startap/screens/auth/ForgotPasswordScreen.dart';
import 'package:startap/screens/onboarding/onboarding_router.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }


  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      
      // Debug print для отладки
      debugPrint('Login attempt: ${_emailController.text.trim()}');
      
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      debugPrint('Login result: success=$success, error=${authProvider.error}');

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (mounted) {
        final errorMessage = authProvider.error ?? 'Ошибка входа';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(errorMessage)),
            backgroundColor: const Color(0xFFFF006E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }


  /// Обработка ошибок от n8n API
  String _getErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('invalid_credentials') || 
        errorLower.contains('неверный') ||
        errorLower.contains('wrong-password')) {
      return 'Неверный email или пароль';
    } else if (errorLower.contains('user-not-found')) {
      return 'Пользователь не найден';
    } else if (errorLower.contains('invalid-email')) {
      return 'Неверный формат email';
    } else if (errorLower.contains('user-disabled')) {
      return 'Учетная запись отключена';
    } else if (errorLower.contains('too-many-requests')) {
      return 'Слишком много попыток входа. Попробуйте позже';
    } else if (errorLower.contains('network') || 
               errorLower.contains('socket') ||
               errorLower.contains('connection') ||
               errorLower.contains('подключения') ||
               errorLower.contains('failed to fetch')) {
      return 'Проблема с подключением. Проверьте интернет';
    } else {
      return error;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 80),
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 12),
                  _buildForgotPassword(),
                  const SizedBox(height: 32),
                  _buildLoginButton(),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildSocialButtons(),
                  const SizedBox(height: 32),
                  _buildRegisterPrompt(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFF4538),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF4538).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            color: Color(0xFFFFFFFF),
            size: 28,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'С возвращением',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Войдите, чтобы продолжить тренировки',
          style: TextStyle(
            color: const Color(0xFFB0B5C0).withOpacity(0.8),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }


  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            color: const Color(0xFFB0B5C0).withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFB0B5C0).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'your@email.com',
              hintStyle: TextStyle(
                color: const Color(0xFFB0B5C0).withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: const Color(0xFFAEAEB2).withOpacity(0.6),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите email';
              }
              if (!value.contains('@')) {
                return 'Введите корректный email';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }


  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Пароль',
          style: TextStyle(
            color: const Color(0xFFB0B5C0).withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFB0B5C0).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(
                color: const Color(0xFFB0B5C0).withOpacity(0.4),
              ),
              prefixIcon: Icon(
                Icons.lock_outlined,
                color: const Color(0xFFAEAEB2).withOpacity(0.6),
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFFB0B5C0).withOpacity(0.5),
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите пароль';
              }
              if (value.length < 6) {
                return 'Минимум 6 символов';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }


  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Забыли пароль?',
          style: TextStyle(
            color: Color(0xFFAEAEB2),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }


  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF4538),
                Color(0xFFFF4538),
              ],
            ),
           
          ),
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
             
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text(
                    'Войти',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        );
      },
    );
  }


  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFB0B5C0).withOpacity(0.2),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'или',
            style: TextStyle(
              color: const Color(0xFFB0B5C0).withOpacity(0.5),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFB0B5C0).withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


    Widget _buildSocialButtons() {
    return Row(
      children: [
        
        
        Expanded(
          child: _buildSocialButton(
            icon: Icons.g_mobiledata_rounded,
            label: 'Google',
            onTap: _handleGoogleLogin, // Вызываем наш обновленный метод
          ),
        ),
      ],
    );
  }

  // Добавь этот метод в класс _LoginScreenState
    Future<void> _handleGoogleLogin() async {
    final authProvider = context.read<AuthProvider>();
    
    // Теперь получаем 'new', 'existing' или null
    final result = await authProvider.signInWithGoogle();

    if (mounted) {
      if (result == 'new') {
        // Впервые зашел через этот Google аккаунт -> на Онбординг
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingRouter()),
        );
      } else if (result == 'existing') {
        // Уже заходил раньше -> на Главную
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (authProvider.error != null) {
        // Ошибка -> показываем красивый SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(authProvider.error!)),
            backgroundColor: const Color(0xFFFF006E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }




  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFB0B5C0).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
                       Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRegisterPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Нет аккаунта?',
          style: TextStyle(
            color: const Color(0xFFB0B5C0).withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Зарегистрироваться',
            style: TextStyle(
              color: Color(0xFFFF4538),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}