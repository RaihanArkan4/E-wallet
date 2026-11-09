import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const BankCentralApp());

// ───────────────────────── Theme ─────────────────────────
class AppColors {
  static const bg = Color(0xFFF8F9FB);
  static const dark = Color(0xFF0F172A);
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const blue = Color(0xFF38BDF8);
  static const green = Color(0xFF10B981);
  static const greenSoft = Color(0xFFE6F8F1);
  static const red = Color(0xFFEF4444);
  static const redSoft = Color(0xFFFDECEC);
}

class BankCentralApp extends StatelessWidget {
  const BankCentralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank Central',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.dark),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// ───────────────────────── Model & State ─────────────────────────
class TransactionItem {
  final int id;
  String title;
  int amount; // selalu positif
  bool isIncome;
  String note;
  String timeLabel;
  String method;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    this.note = '',
    this.timeLabel = 'Hari ini, 10:00',
    this.method = 'Transfer Bank',
  });
}

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  String userName = 'Andi Pratama';
  int _nextId = 4;

  final List<TransactionItem> transactions = [
    TransactionItem(
      id: 1,
      title: 'Gaji Bulanan',
      amount: 5000000,
      isIncome: true,
      note: 'Gaji pokok bulan ini',
      timeLabel: 'Hari ini, 10:00',
    ),
    TransactionItem(
      id: 2,
      title: 'Belanja Bulanan',
      amount: 450000,
      isIncome: false,
      note: 'Belanja kebutuhan rumah',
      timeLabel: 'Kemarin, 18:30',
      method: 'Kartu Debit',
    ),
    TransactionItem(
      id: 3,
      title: 'Transfer dari Ibu',
      amount: 3200000,
      isIncome: true,
      note: 'Kiriman bulanan',
      timeLabel: 'Senin, 09:15',
    ),
  ];

  int get totalIncome =>
      transactions.where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);
  int get totalExpense =>
      transactions.where((t) => !t.isIncome).fold(0, (s, t) => s + t.amount);
  int get balance => totalIncome - totalExpense;

  TransactionItem? byId(int id) {
    for (final t in transactions) {
      if (t.id == id) return t;
    }
    return null;
  }

  void add(String title, int amount, bool isIncome, String note) {
    transactions.insert(
      0,
      TransactionItem(
        id: _nextId++,
        title: title,
        amount: amount,
        isIncome: isIncome,
        note: note,
        timeLabel: 'Hari ini, ${_now()}',
      ),
    );
    notifyListeners();
  }

  void update(int id, String title, int amount, String note) {
    final t = byId(id);
    if (t == null) return;
    t.title = title;
    t.amount = amount;
    t.note = note;
    notifyListeners();
  }

  void remove(int id) {
    transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  String _now() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
  }
}

String rupiah(int value) {
  final s = value.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

int parseAmount(String s) =>
    int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

// ───────────────────────── Reusable widgets ─────────────────────────
class AppField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final int maxLines;
  final TextInputType? keyboardType;

  const AppField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscure,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13, color: AppColors.text),
            decoration: _inputDecoration(hint),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.dark),
      ),
    );

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const PrimaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

AppBar buildAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: AppColors.bg,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.text),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(title,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 12),
        child: Icon(Icons.more_horiz, size: 20, color: AppColors.text),
      ),
    ],
  );
}

// ───────────────────────── Splash ─────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F2937), Color(0xFF6B7280)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                  color: Color(0xFF1E293B), shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 24),
            const Text('Bank Central',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Atur Keuanganmu dengan Mudah',
                style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Login ─────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Masuk',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text)),
              const SizedBox(height: 6),
              const Text('Selamat datang kembali!',
                  style: TextStyle(fontSize: 13, color: AppColors.muted)),
              const SizedBox(height: 40),
              AppField(
                  label: 'Email',
                  hint: 'nama@email.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress),
              AppField(
                  label: 'Kata Sandi',
                  hint: '••••••••',
                  controller: _pass,
                  obscure: true),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Masuk',
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen())),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text.rich(TextSpan(
                    text: 'Belum punya akun? ',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                    children: [
                      TextSpan(
                          text: 'Daftar',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text)),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Register ─────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daftar',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text)),
              const SizedBox(height: 6),
              const Text('Buat akun untuk memulai',
                  style: TextStyle(fontSize: 13, color: AppColors.muted)),
              const SizedBox(height: 40),
              AppField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama',
                  controller: _name),
              AppField(
                  label: 'Email',
                  hint: 'nama@email.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress),
              AppField(
                  label: 'Kata Sandi',
                  hint: '••••••••',
                  controller: _pass,
                  obscure: true),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Daftar',
                onPressed: () {
                  if (_name.text.trim().isNotEmpty) {
                    AppState.instance.userName = _name.text.trim();
                  }
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (_) => false);
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text.rich(TextSpan(
                    text: 'Sudah punya akun? ',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                    children: [
                      TextSpan(
                          text: 'Masuk',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text)),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Dialogs ─────────────────────────
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required Color iconBg,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  required Color confirmColor,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, height: 1.4, color: AppColors.muted)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(cancelLabel,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(confirmLabel,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool?> showDeleteDialog(BuildContext context) => showConfirmDialog(
      context,
      icon: Icons.delete_outline,
      iconColor: AppColors.red,
      iconBg: AppColors.redSoft,
      title: 'Hapus Transaksi?',
      message:
          'Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.',
      cancelLabel: 'Batal',
      confirmLabel: 'Hapus',
      confirmColor: AppColors.red,
    );

Future<bool?> showLogoutDialog(BuildContext context) => showConfirmDialog(
      context,
      icon: Icons.logout,
      iconColor: AppColors.text,
      iconBg: AppColors.bg,
      title: 'Keluar dari Akun?',
      message:
          'Anda akan keluar dari akun ${AppState.instance.userName}. Apakah Anda yakin ingin melanjutkan?',
      cancelLabel: 'Tidak',
      confirmLabel: 'Keluar',
      confirmColor: AppColors.dark,
    );

// ───────────────────────── Home ─────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: AppColors.border, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(
                        state.userName.isNotEmpty
                            ? state.userName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selamat datang,',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.muted)),
                          Text(state.userName,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const Icon(Icons.notifications_none,
                        size: 20, color: AppColors.text),
                  ],
                ),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddTransactionScreen())),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Tambah Transaksi',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final ok = await showLogoutDialog(context);
                            if (ok == true && context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                  (_) => false);
                            }
                          },
                          icon: const Icon(Icons.logout,
                              size: 14, color: AppColors.red),
                          label: const Text('Keluar',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.red)),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Balance card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Saldo • ${state.transactions.length} transaksi',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFCBD5E1))),
                                const SizedBox(height: 4),
                                Text(rupiah(state.balance),
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: const Color(0xFF1E3A5F),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.account_balance_wallet,
                                size: 18, color: AppColors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryItem(
                                label: 'Pemasukan',
                                value: rupiah(state.totalIncome),
                                color: AppColors.green),
                          ),
                          Expanded(
                            child: _SummaryItem(
                                label: 'Pengeluaran',
                                value: rupiah(state.totalExpense),
                                color: AppColors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Riwayat Transaksi',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    Text('Lihat Semua',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blue)),
                  ],
                ),
                const SizedBox(height: 12),
                ...state.transactions.map((t) => _TransactionTile(item: t)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 9, color: Color(0xFFCBD5E1))),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionItem item;
  const _TransactionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isIncome ? AppColors.green : AppColors.red;
    final soft = item.isIncome ? AppColors.greenSoft : AppColors.redSoft;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailScreen(id: item.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: soft, borderRadius: BorderRadius.circular(8)),
              child: Icon(
                  item.isIncome ? Icons.south_west : Icons.shopping_cart_outlined,
                  size: 16,
                  color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(item.timeLabel,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.muted)),
                ],
              ),
            ),
            Text('${item.isIncome ? '+' : '-'}${rupiah(item.amount)}',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Add Transaction ─────────────────────────
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool? _isIncome;

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final amount = parseAmount(_amount.text);
    if (_title.text.trim().isEmpty || amount == 0 || _isIncome == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lengkapi judul, nominal, dan tipe transaksi')));
      return;
    }
    AppState.instance
        .add(_title.text.trim(), amount, _isIncome!, _note.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Tambah Transaksi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppField(
                label: 'Judul Transaksi',
                hint: 'Contoh: Beli Makan Siang',
                controller: _title),
            AppField(
                label: 'Nominal',
                hint: 'Rp 0',
                controller: _amount,
                keyboardType: TextInputType.number),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tipe Transaksi',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<bool>(
                    initialValue: _isIncome,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.text),
                    decoration: _inputDecoration('Pilih Pemasukan/Pengeluaran'),
                    items: const [
                      DropdownMenuItem(value: true, child: Text('Pemasukan')),
                      DropdownMenuItem(
                          value: false, child: Text('Pengeluaran')),
                    ],
                    onChanged: (v) => setState(() => _isIncome = v),
                  ),
                ],
              ),
            ),
            AppField(
                label: 'Catatan',
                hint: 'Tambahkan catatan opsional...',
                controller: _note,
                maxLines: 4),
            const SizedBox(height: 4),
            PrimaryButton(label: 'Simpan Transaksi', onPressed: _save),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Detail ─────────────────────────
class DetailScreen extends StatelessWidget {
  final int id;
  const DetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final t = state.byId(id);
        if (t == null) return const Scaffold();
        final color = t.isIncome ? AppColors.green : AppColors.red;
        final soft = t.isIncome ? AppColors.greenSoft : AppColors.redSoft;
        return Scaffold(
          appBar: buildAppBar(context, 'Detail Transaksi'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration:
                            BoxDecoration(color: soft, shape: BoxShape.circle),
                        child: Icon(
                            t.isIncome
                                ? Icons.south_west
                                : Icons.north_east,
                            size: 20,
                            color: color),
                      ),
                      const SizedBox(height: 16),
                      Text('${t.isIncome ? '+' : '-'}${rupiah(t.amount)}',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: color)),
                      const SizedBox(height: 8),
                      Text(t.title,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text(
                          '${t.isIncome ? 'Pemasukan' : 'Pengeluaran'} • ${t.timeLabel}',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.muted)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _DetailRow(
                    label: 'Kategori',
                    value: t.isIncome ? 'Pemasukan' : 'Pengeluaran'),
                _DetailRow(
                    label: 'Catatan', value: t.note.isEmpty ? '-' : t.note),
                _DetailRow(label: 'Metode', value: t.method),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => EditTransactionScreen(id: id))),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.text,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Edit',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () async {
                            final ok = await showDeleteDialog(context);
                            if (ok == true && context.mounted) {
                              state.remove(id);
                              Navigator.pop(context);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.red,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Hapus',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Edit ─────────────────────────
class EditTransactionScreen extends StatefulWidget {
  final int id;
  const EditTransactionScreen({super.key, required this.id});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final t = AppState.instance.byId(widget.id)!;
    _title = TextEditingController(text: t.title);
    _amount = TextEditingController(text: rupiah(t.amount));
    _note = TextEditingController(text: t.note);
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Edit Transaksi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppField(
                label: 'Judul Transaksi', hint: '', controller: _title),
            AppField(
                label: 'Nominal',
                hint: '',
                controller: _amount,
                keyboardType: TextInputType.number),
            AppField(
                label: 'Catatan', hint: '', controller: _note, maxLines: 4),
            const SizedBox(height: 4),
            PrimaryButton(
              label: 'Perbarui Transaksi',
              onPressed: () {
                final amount = parseAmount(_amount.text);
                if (_title.text.trim().isEmpty || amount == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Judul dan nominal wajib diisi')));
                  return;
                }
                AppState.instance.update(
                    widget.id, _title.text.trim(), amount, _note.text.trim());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}