import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/di/service_locator.dart';
import '../../../news/ui/pages/main_page.dart';
import '../cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
      suffixIcon: suffix,
      filled: true,
      fillColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? Colors.white
            : const Color(0xFFF1F1F1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) async {
                  if (state is AuthSuccess) {
                    // Показываем локальное уведомление при успешном входе
                    try {
                      final FlutterLocalNotificationsPlugin localNotif = FlutterLocalNotificationsPlugin();
                      await localNotif.show(
                        0,
                        'Успешный вход! 🎉',
                        'Добро пожаловать в приложение!',
                        const NotificationDetails(
                          android: AndroidNotificationDetails(
                            'high_importance_channel',
                            'High Importance Notifications',
                            importance: Importance.max,
                            priority: Priority.high,
                            icon: '@mipmap/ic_launcher',
                          ),
                        ),
                      );
                    } catch (e) {
                      print('Ошибка показа уведомления: $e');
                    }

                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainPage()),
                    );
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  final loading = state is AuthLoading;
                  void submit() => context
                      .read<AuthCubit>()
                      .login(_login.text, _password.text);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 88),
                        const Row(
                          children: [
                            Icon(Icons.table_chart_outlined, size: 28),
                            SizedBox(width: 14),
                            Text(
                              'News App',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Divider(height: 1, color: Colors.grey.shade200),
                        const SizedBox(height: 56),
                        const Text(
                          'С возвращением',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Войдите, чтобы читать новости.',
                          style: TextStyle(
                              fontSize: 15, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 44),
                        _label('Логин'),
                        TextField(
                          controller: _login,
                          textInputAction: TextInputAction.next,
                          decoration: _decoration('Введите логин'),
                        ),
                        const SizedBox(height: 28),
                        _label('Пароль'),
                        TextField(
                          controller: _password,
                          obscureText: _obscure,
                          onSubmitted: (_) => submit(),
                          decoration: _decoration(
                            'Введите пароль',
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: loading ? null : submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Войти',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}