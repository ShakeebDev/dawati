import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/auth/presentation/providers/auth_provider.dart';
import 'package:dawati/core/utils/app_utils.dart';

import 'package:dawati/core/widgets/responsive_wrapper.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'organizer';

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _selectedRole,
          );

      if (success && mounted) {
        context.go('/dashboard');
      } else if (mounted) {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error?.message ?? 'فشل إنشاء الحساب')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: ResponsiveWrapper(
        maxWidth: 450,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon: Icon(Icons.person_outline)),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'يرجى إدخال الاسم' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    AppUtils.isValidEmail(value ?? '') ? null : 'بريد غير صالح',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                    labelText: 'رقم الجوال',
                    prefixIcon: Icon(Icons.phone_outlined)),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'يرجى إدخال الجوال' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
                validator: (value) =>
                    (value?.length ?? 0) < 6 ? 'كلمة المرور قصيرة جداً' : null,
              ),
              const SizedBox(height: 24),
              const Text('اختر نوع الحساب:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      label: 'منظم مناسبات',
                      icon: Icons.event,
                      isSelected: _selectedRole == 'organizer',
                      onTap: () => setState(() => _selectedRole = 'organizer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoleCard(
                      label: 'موظف استقبال',
                      icon: Icons.qr_code_scanner,
                      isSelected: _selectedRole == 'staff',
                      onTap: () => setState(() => _selectedRole = 'staff'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleRegister,
                child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تسجيل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard(
      {required this.label,
      required this.icon,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldPrimary.withOpacity(0.1)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? AppTheme.goldPrimary
                  : Theme.of(context).dividerColor.withOpacity(0.1),
              width: 2),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppTheme.goldPrimary
                    : Theme.of(context).hintColor),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: isSelected
                        ? AppTheme.goldPrimary
                        : Theme.of(context).hintColor,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
