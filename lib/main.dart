import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/waste_provider.dart';
import 'providers/reminder_provider.dart';

import 'screens/login_page.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SmartRecycleApp());
}

class SmartRecycleApp extends StatelessWidget {
  const SmartRecycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WasteProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SmartRecycle SG',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastUid;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final uid = auth.user?.uid;

    if (_lastUid != uid) {
      _lastUid = uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ReminderProvider>().bindToUser(uid);
      });
    }

    if (auth.user == null) return const LoginPage();
    return const MainShell();
  }
}

class _ReminderBinder extends StatefulWidget {
  final String? uid;
  final Widget child;

  const _ReminderBinder({required this.uid, required this.child});

  @override
  State<_ReminderBinder> createState() => _ReminderBinderState();
}

class _ReminderBinderState extends State<_ReminderBinder> {
  String? _lastUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeBind();
  }

  @override
  void didUpdateWidget(covariant _ReminderBinder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeBind();
  }

  void _maybeBind() {
    if (_lastUid == widget.uid) return;
    _lastUid = widget.uid;
    context.read<ReminderProvider>().bindToUser(widget.uid);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
