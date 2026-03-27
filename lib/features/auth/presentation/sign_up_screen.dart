import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/auth_notifier.dart';

/// アカウント作成画面Widget
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _connpassController = TextEditingController();
  bool _isPasswordVisible = false;
  int _currentStep = 0; // 0: 基本情報, 1: ロール選択
  String _selectedRole = 'other';

  /// 選択可能なロール一覧
  final _roles = [
    {'value': 'frontend', 'label': 'フロントエンド', 'icon': '🎨'},
    {'value': 'backend', 'label': 'バックエンド', 'icon': '⚙️'},
    {'value': 'fullstack', 'label': 'フルスタック', 'icon': '🚀'},
    {'value': 'other', 'label': 'その他', 'icon': '💡'},
  ];

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _connpassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // サインアップ成功時・エラー時の処理
    ref.listen(authNotifierProvider, (_, next) {
      next.when(
        data: (user) {
          if (user != null) context.go('/home');
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.redAccent,
            ),
          );
        },
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          _currentStep == 0 ? '新規登録' : 'ロール選択',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _currentStep == 0
            ? _buildBasicInfoStep()
            : _buildRoleSelectionStep(),
      ),
    );
  }

  /// ステップ1: 基本情報入力
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _idController,
              label: 'ユーザーID（半角英数字）',
              icon: Icons.badge_outlined,
              validator: (v) {
                if (v == null || v.isEmpty) return 'ユーザーIDを入力してください';
                if (v.length < 3) return '3文字以上で入力してください';
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
                  return '半角英数字とアンダースコアのみ使用できます';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: '表示名',
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.isEmpty) ? '表示名を入力してください' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'メールアドレス',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'メールアドレスを入力してください';
                if (!v.contains('@')) return '正しいメールアドレスを入力してください';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              style: const TextStyle(color: Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                labelText: 'パスワード',
                labelStyle: const TextStyle(color: Color(0xFF757575)),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF757575),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: const Color(0xFF757575),
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
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
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'パスワードを入力してください';
                if (v.length < 6) return '6文字以上で入力してください';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _connpassController,
              label: 'ConnpassユーザーID（任意）',
              icon: Icons.link,
              validator: null, // 任意なのでバリデーションなし
            ),
            const SizedBox(height: 8),
            const Text(
              '※ Connpassアカウントを連携すると、イベント情報を取得できます',
              style: TextStyle(color: Color(0xFF757575), fontSize: 12),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() => _currentStep = 1);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3AAA3A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '次へ →',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ステップ2: ロール選択
  Widget _buildRoleSelectionStep() {
    final authState = ref.watch(authNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'あなたの専門分野を選んでください',
            style: TextStyle(color: Color(0xFF757575), fontSize: 14),
          ),
          const SizedBox(height: 24),
          ...List.generate(_roles.length, (index) {
            final role = _roles[index];
            final isSelected = _selectedRole == role['value'];
            return _RoleOption(
              label: role['label']!,
              icon: role['icon']!,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedRole = role['value']!),
            );
          }),
          const Spacer(),
          ElevatedButton(
            onPressed: authState.isLoading ? null : _handleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3AAA3A),
              disabledBackgroundColor:
                  const Color(0xFF3AAA3A).withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'アカウントを作成',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// サインアップ処理を実行する
  void _handleSignUp() {
    ref
        .read(authNotifierProvider.notifier)
        .signUp(
          id: _idController.text.trim(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
          connpassUrl: _connpassController.text.trim(),
        );
  }

  /// テキストフィールドの共通ビルダー
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Color(0xFF1A1A1A)),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF757575)),
        prefixIcon: Icon(icon, color: const Color(0xFF757575)),
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
      ),
      validator: validator,
    );
  }
}

/// ロール選択オプションWidget
class _RoleOption extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3AAA3A).withValues(alpha: 0.1)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF3AAA3A)
                  : const Color(0xFFE0E0E0),
            ),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF3AAA3A)
                      : const Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle, color: Color(0xFF3AAA3A)),
            ],
          ),
        ),
      ),
    );
  }
}
