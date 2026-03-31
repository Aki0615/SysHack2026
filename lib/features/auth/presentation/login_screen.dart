import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/auth_notifier.dart';

/// ログイン画面Widget
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 入力が変更されたらエラーメッセージをクリアする
  void _clearErrorIfNeeded() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // ログイン成功時・エラー時の処理
    ref.listen(authNotifierProvider, (_, next) {
      next.when(
        data: (user) {
          if (user != null) {
            setState(() => _errorMessage = null);
            context.go('/home');
          }
        },
        error: (error, _) {
          // エラーメッセージを解析してユーザーフレンドリーなメッセージに変換
          String message = _parseErrorMessage(error);
          setState(() => _errorMessage = message);
        },
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 48),
                if (_errorMessage != null) ...[
                  _buildErrorBanner(),
                  const SizedBox(height: 16),
                ],
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 32),
                _buildLoginButton(authState),
                const SizedBox(height: 16),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// エラーメッセージを解析してユーザーフレンドリーなメッセージに変換
  String _parseErrorMessage(Object error) {
    final errorStr = error.toString().toLowerCase();
    // 認証エラー（401）やパスワード・メール関連のエラー
    if (errorStr.contains('401') ||
        errorStr.contains('unauthorized') ||
        errorStr.contains('invalid') ||
        errorStr.contains('incorrect') ||
        errorStr.contains('password') ||
        errorStr.contains('email') ||
        errorStr.contains('credentials')) {
      return 'メールアドレスまたはパスワードが正しくありません';
    }
    // ネットワークエラー
    if (errorStr.contains('timeout') ||
        errorStr.contains('connection') ||
        errorStr.contains('network') ||
        errorStr.contains('socket')) {
      return 'ネットワークに接続できません。接続を確認してください';
    }
    // サーバーエラー
    if (errorStr.contains('500') || errorStr.contains('server')) {
      return 'サーバーエラーが発生しました。しばらくしてからお試しください';
    }
    // その他のエラー
    return 'ログインに失敗しました。入力内容を確認してください';
  }

  /// エラーバナーWidget
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFE53935),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: const Icon(
              Icons.close,
              color: Color(0xFF757575),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// ヘッダー（ロゴとタイトル）
  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/images/app_icon.png',
          width: 80,
          height: 80,
        ),
        const SizedBox(height: 16),
        const Text(
          'Passly',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'ログインしてすれ違いを始めよう',
          style: TextStyle(color: Color(0xFF757575), fontSize: 14),
        ),
      ],
    );
  }

  /// メールアドレス入力フィールド
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: const TextStyle(color: Color(0xFF1A1A1A)),
      keyboardType: TextInputType.emailAddress,
      onChanged: (_) => _clearErrorIfNeeded(),
      decoration: _inputDecoration(
        label: 'メールアドレス',
        icon: Icons.email_outlined,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'メールアドレスを入力してください';
        if (!value.contains('@')) return '正しいメールアドレスを入力してください';
        return null;
      },
    );
  }

  /// パスワード入力フィールド
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Color(0xFF1A1A1A)),
      onChanged: (_) => _clearErrorIfNeeded(),
      decoration: _inputDecoration(
        label: 'パスワード',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF757575),
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'パスワードを入力してください';
        if (value.length < 6) return 'パスワードは6文字以上で入力してください';
        return null;
      },
    );
  }

  /// ログインボタン
  Widget _buildLoginButton(AsyncValue authState) {
    final isLoading = authState.isLoading;
    return ElevatedButton(
      onPressed: isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3AAA3A),
        disabledBackgroundColor: const Color(0xFF3AAA3A).withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'ログイン',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  /// アカウント作成画面へのリンク
  Widget _buildSignUpLink() {
    return TextButton(
      onPressed: () => context.push('/signup'),
      child: RichText(
        text: const TextSpan(
          text: 'アカウントをお持ちでない方は',
          style: TextStyle(color: Color(0xFF757575)),
          children: [
            TextSpan(
              text: '新規登録',
              style: TextStyle(
                color: Color(0xFF3AAA3A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ログイン処理の実行
  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authNotifierProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  /// 入力フィールドの共通デコレーション
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF757575)),
      prefixIcon: Icon(icon, color: const Color(0xFF757575)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3AAA3A)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
