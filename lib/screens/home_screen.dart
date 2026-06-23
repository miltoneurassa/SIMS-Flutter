import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../common/theme.dart';
import '../common/services/storage_service.dart';
import '../common/services/api_service.dart';
import '../common/models/user_model.dart';
import '../widgets/dashboard_card.dart';
import 'login_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  bool _isLoading = false;

  static final List<DashboardItem> _menuItems = [
    DashboardItem(
      id: 1,
      label: 'Registration',
      icon: Icons.how_to_reg_rounded,
      color: const Color(0xFF1565C0),
      actionKey: 'REGISTRATION',
    ),
    DashboardItem(
      id: 2,
      label: 'Payments',
      icon: Icons.payment_rounded,
      color: const Color(0xFF2E7D32),
      actionKey: 'PAYMENTS',
    ),
    DashboardItem(
      id: 3,
      label: 'Exam Number',
      icon: Icons.assignment_rounded,
      color: const Color(0xFFE65100),
      actionKey: 'EXAMINATION_NUMBER',
    ),
    DashboardItem(
      id: 4,
      label: 'Allocation',
      icon: Icons.room_rounded,
      color: const Color(0xFF6A1B9A),
      actionKey: 'ALLOCATION',
    ),
    DashboardItem(
      id: 5,
      label: 'Outstanding Balance',
      icon: Icons.account_balance_wallet_rounded,
      color: const Color(0xFFC62828),
      actionKey: 'OUTSTANDING_BALANCE',
    ),
    DashboardItem(
      id: 6,
      label: 'ID Card',
      icon: Icons.badge_rounded,
      color: const Color(0xFF00695C),
      actionKey: 'ID_CARD',
    ),
    DashboardItem(
      id: 7,
      label: 'Results',
      icon: Icons.grade_rounded,
      color: const Color(0xFF283593),
      actionKey: 'EXAMINATION',
    ),
    DashboardItem(
      id: 8,
      label: 'Student Details',
      icon: Icons.person_search_rounded,
      color: const Color(0xFF00838F),
      actionKey: 'STUDENT_DETAILS',
    ),
    DashboardItem(
      id: 9,
      label: 'Verify Exam Card',
      icon: Icons.verified_rounded,
      color: const Color(0xFFF57F17),
      actionKey: 'EXAMINATION_NUMBER_VERIFY',
    ),
    DashboardItem(
      id: 10,
      label: 'Attendance',
      icon: Icons.checklist_rounded,
      color: const Color(0xFFAD1457),
      actionKey: 'ATTENDANCE',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.instance.getUser();
    if (mounted) setState(() => _user = user);
  }

  Future<bool> _hasNetwork() async {
    final result = await Connectivity().checkConnectivity();
    return result.first != ConnectivityResult.none;
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<String> _getDeviceId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      return android.id;
    } else if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return ios.identifierForVendor ?? 'unknown';
    }
    return 'unknown';
  }

  void _onMenuTap(DashboardItem item) {
    if (item.actionKey == 'ATTENDANCE') {
      _startAttendance();
    } else {
      _showInputSheet(item);
    }
  }

  void _showInputSheet(DashboardItem item) {
    final regCtrl = TextEditingController();
    final now = DateTime.now();
    final defaultYear = '${now.year}/${now.year + 1}';
    final yearCtrl = TextEditingController(text: defaultYear);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ]),
              const SizedBox(height: 24),

              // Reg number field
              Text('Registration Number',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: regCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. 2021/CS/001',
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: item.color, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Academic year field
              Text('Academic Year',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: yearCtrl,
                decoration: InputDecoration(
                  hintText: defaultYear,
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: item.color, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Load button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search_rounded),
                  label: Text('Load', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final reg = regCtrl.text.trim();
                    if (reg.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a registration number',
                              style: GoogleFonts.poppins(fontSize: 13)),
                          backgroundColor: AppTheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop();
                    _fetchByRegNumber(
                      regNo: reg,
                      ayear: yearCtrl.text.trim().isEmpty ? defaultYear : yearCtrl.text.trim(),
                      destination: item.actionKey,
                      label: item.label,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Divider with OR
              Row(children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ]),

              const SizedBox(height: 16),

              // Scan QR button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.qr_code_scanner_rounded, color: item.color),
                  label: Text('Scan QR Code',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: item.color)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: item.color, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _openQRScanner(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openQRScanner(DashboardItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _QRScannerScreen(
          title: item.label,
          actionKey: item.actionKey,
          color: item.color,
          onScanned: (data) => _processQRCode(data, item.actionKey),
        ),
      ),
    );
  }

  Future<void> _fetchByRegNumber({
    required String regNo,
    required String ayear,
    required String destination,
    required String label,
  }) async {
    final hasNetwork = await _hasNetwork();
    if (!hasNetwork) { _showError('No network connection'); return; }

    final baseUrl = await StorageService.instance.getSiteUrl();
    if (baseUrl.isEmpty) { _showError('Base URL not configured'); return; }

    setState(() => _isLoading = true);

    final deviceId = await _getDeviceId();
    final result = await ApiService.instance.verifyQRCode(
      baseUrl: baseUrl,
      payload: {
        'userid': _user?.userId ?? '',
        'username': _user?.username ?? '',
        'device_date': _getCurrentDate(),
        'device_id': deviceId,
        'version': 1.0,
        'card_no': '',
        'regNo': regNo,
        'ayear': ayear,
        'section': destination,
      },
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _showResultScreen(label, result.data, section: destination);
    } else {
      _showError(result.message);
    }
  }

  Future<void> _processQRCode(String data, String destination) async {
    Navigator.of(context).pop(); // close scanner

    final parts = data.split('|');

    if (destination == 'EXAMINATION_NUMBER_VERIFY') {
      if (parts.length == 7) {
        _showResultScreen('Exam Card Verified', {'data': parts});
      } else {
        _showError('Invalid QR Code format for Student Examination ID');
      }
      return;
    }

    if (parts.length != 3) {
      _showError('Invalid QR Code format for Student ID');
      return;
    }

    final hasNetwork = await _hasNetwork();
    if (!hasNetwork) {
      _showError('No network connection');
      return;
    }

    final baseUrl = await StorageService.instance.getSiteUrl();
    if (baseUrl.isEmpty) {
      _showError('Base URL not configured');
      return;
    }

    setState(() => _isLoading = true);

    final deviceId = await _getDeviceId();
    final result = await ApiService.instance.verifyQRCode(
      baseUrl: baseUrl,
      payload: {
        'userid': _user?.userId ?? '',
        'username': _user?.username ?? '',
        'device_date': _getCurrentDate(),
        'device_id': deviceId,
        'version': 1.0,
        'card_no': parts[0],
        'regNo': parts[1],
        'ayear': parts[2],
        'section': destination,
      },
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _showResultScreen(destination.replaceAll('_', ' '), result.data, section: destination);
    } else {
      _showError(result.message);
    }
  }

  Future<void> _startAttendance() async {
    final hasNetwork = await _hasNetwork();
    if (!hasNetwork) {
      _showError('No network connection');
      return;
    }

    final baseUrl = await StorageService.instance.getSiteUrl();
    if (baseUrl.isEmpty) {
      _showError('Base URL not configured. Please re-login.');
      return;
    }

    setState(() => _isLoading = true);

    final deviceId = await _getDeviceId();
    final result = await ApiService.instance.startAttendance(
      baseUrl: baseUrl,
      payload: {
        'userid': _user?.userId ?? '',
        'username': _user?.username ?? '',
        'device_date': _getCurrentDate(),
        'device_id': deviceId,
        'version': 1.0,
      },
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _showResultScreen('Attendance', result.data, section: 'ATTENDANCE');
    } else {
      _showError(result.message);
    }
  }

  void _showResultScreen(String title, dynamic data, {String section = ''}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportScreen(title: title, data: data, section: section),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Sign Out', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.instance.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final college = _user?.college ?? '';
    final userName = _user?.username ?? '';
    final fullName = _user?.fullName ?? '';
    final groupName = _user?.groupName ?? '';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                backgroundColor: AppTheme.primary,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    onPressed: _logout,
                    tooltip: 'Sign Out',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(gradient: AppTheme.headerGradient),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // College banner
                            Row(
                              children: [
                                const Icon(
                                  Icons.school_rounded,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    college.isEmpty ? 'SIMS' : college,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 100.ms),

                            const SizedBox(height: 20),

                            // User info row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Avatar
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.3),
                                        Colors.white.withOpacity(0.15),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 2.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initial,
                                      style: GoogleFonts.poppins(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fullName.isEmpty ? 'User' : fullName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      _tag(userName, Icons.person_outline_rounded),
                                      const SizedBox(height: 4),
                                      _tag(groupName, Icons.group_outlined),
                                    ],
                                  ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  collapseMode: CollapseMode.parallax,
                  title: Text(
                    'SIMS Dashboard',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: false,
                ),
              ),

              // Dashboard label
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    children: [
                      Text(
                        'Modules',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_menuItems.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dashboard grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _menuItems[index];
                      return DashboardCard(
                        item: item,
                        onTap: () => _onMenuTap(item),
                        animationIndex: index,
                      );
                    },
                    childCount: _menuItems.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.45),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Please wait...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tag(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.white60),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// QR Scanner for home modules
class _QRScannerScreen extends StatefulWidget {
  final String title;
  final String actionKey;
  final Color color;
  final void Function(String data) onScanned;

  const _QRScannerScreen({
    required this.title,
    required this.actionKey,
    required this.color,
    required this.onScanned,
  });

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  bool _scanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null) return;
    _scanned = true;
    widget.onScanned(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),

          // Dimmed overlay with cutout effect
          IgnorePointer(
            child: ColoredBox(
              color: Colors.transparent,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.color, width: 2.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Scan Student QR Code',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
