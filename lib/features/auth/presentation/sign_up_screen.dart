import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/auth_notifier.dart';
import '../../user/domain/user_role.dart';

/// アカウント作成画面Widget
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.other;
  int _currentStep = 0; // ステッパーの現在位置

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // サインアップ成功時にホーム画面へ遷移
    ref.listen(authNotifierProvider, (_, next) {
      next.whenData((user) {
        if (user != null) context.go('/home');
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('アカウント作成', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStepIndicator(),
                const SizedBox(height: 32),
                if (_currentStep == 0) _buildBasicInfoStep(),
                if (_currentStep == 1) _buildRoleStep(),
                const SizedBox(height: 32),
                _buildNavigationButtons(authState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ステップインジケーター（2ステップ）
  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(2, (index) {
        final isActive = index <= _currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.blueAccent : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  /// ステップ1: 基本情報の入力（名前・メール・パスワード）
  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '基本情報を入力',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _nameController,
          label: '名前',
          icon: Icons.person_outline,
          validator: (v) => (v == null || v.isEmpty) ? '名前を入力してください' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'メールアドレス',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return 'メールアドレスを入力してください';
            if (!v.contains('@')) return '正しいメールアドレスを入力してください';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'パスワード（6文字以上）',
          icon: Icons.lock_outline,
          obscure: true,
          validator: (v) {
            if (v == null || v.isEmpty) return 'パスワードを入力してください';
            if (v.length < 6) return 'パスワードは6文字以上にしてください';
            return null;
          },
        ),
      ],
    );
  }

  /// ステップ2: ロール（役割）の選択
  Widget _buildRoleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'あなたの役割を教えてください',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'すれ違った相手に表示されます',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        const SizedBox(height: 24),
        ...UserRole.values.map((role) => _buildRoleOption(role)),
      ],
    );
  }

  /// ロール選択のラジオボタン風タイル
  Widget _buildRoleOption(UserRole role) {
    final isSelected = _selectedRole == role;
    final roleLabels = {
      UserRole.frontend: ('🎨', 'フロントエンド'),
      UserRole.backend: ('⚙️', 'バックエンド'),
      UserRole.fullstack: ('🚀', 'フルスタック'),
      UserRole.other: ('💻', 'その他'),
    };
    final label = roleLabels[role]!;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withValues(alpha: 0.15)
              : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
          ),
        ),
        child: Row(
          children: [
            Text(label.$1, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              label.$2,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  /// 「次へ」「戻る」「登録する」ボタン群
  Widget _buildNavigationButtons(AsyncValue authState) {
    final isLoading = authState.isLoading;
    return Row(
      children: [
        // 戻るボタン（ステップ2のみ表示）
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade700),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('戻る', style: TextStyle(color: Colors.white)),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        // 次へ / 登録するボタン
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                : Text(
                    _currentStep == 0 ? '次へ' : '登録する',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// 「次へ」/「登録する」ボタンのハンドラ
  void _handleNext() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _currentStep = 1);
    } else {
      // ステップ2で登録する
      ref
          .read(authNotifierProvider.notifier)
          .signUp(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  /// テキストフィールドの共通ビルダー
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }
}
