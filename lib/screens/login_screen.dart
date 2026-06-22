import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../common/theme.dart';
import '../common/config.dart';
import '../common/models/user_model.dart';
import '../common/services/storage_service.dart';
import '../common/services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
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

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<bool> _hasNetwork() async {
    final result = await Connectivity().checkConnectivity();
    return result.first != ConnectivityResult.none;
  }

  void _showError(String msg) {
    setState(() => _errorMessage = msg);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final baseUrl = await StorageService.instance.getSiteUrl();
    if (baseUrl.isEmpty) {
      _showError('Please scan your SIMS QR Code first to configure the app.');
      return;
    }

    final hasNetwork = await _hasNetwork();
    if (!hasNetwork) {
      _showError('No network connection. Please check your internet.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final deviceId = await _getDeviceId();
    final result = await ApiService.instance.login(
      baseUrl: baseUrl,
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      deviceDate: _getCurrentDate(),
      deviceId: deviceId,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      final user = UserModel.fromJson(result.data);
      await StorageService.instance.saveUser(user);
      await StorageService.instance.setSiteUrl(result.data['site_url'] ?? '');
      await StorageService.instance.setCollegeName(result.data['college'] ?? '');

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      _showError(result.message);
    }
  }

  Future<void> _openQRScanner() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _QRLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: size.height * 0.45,
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
          ),

          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    // Logo + header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                          const SizedBox(height: 16),

                          Text(
                            'SIMS',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),

                          Text(
                            'Welcome back',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ).animate(delay: 200.ms).fadeIn(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.12),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enter your credentials to continue',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Error banner
                            if (_errorMessage.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.error.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: AppTheme.error,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn().shakeX(hz: 3),

                            // Username field
                            TextFormField(
                              controller: _usernameCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: 'Enter your username',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Username is required' : null,
                            ),

                            const SizedBox(height: 16),

                            // Password field
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Password is required' : null,
                            ),

                            const SizedBox(height: 28),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.login_rounded, size: 20),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Sign In',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppTheme.divider)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'or',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: AppTheme.divider)),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // QR Login button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _openQRScanner,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppTheme.primary.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_scanner_rounded,
                                      color: AppTheme.primary,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Scan QR Code to Login',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 500.ms).fadeIn(),

                    const SizedBox(height: 32),

                    // Footer
                    Center(
                      child: Text(
                        'Powered by ICT Solutions Design',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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

// QR Login Screen
class _QRLoginScreen extends StatefulWidget {
  const _QRLoginScreen();

  @override
  State<_QRLoginScreen> createState() => _QRLoginScreenState();
}

class _QRLoginScreenState extends State<_QRLoginScreen> {
  bool _scanned = false;

  void _onQRDetected(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    _scanned = true;
    final data = barcode!.rawValue!;
    final parts = data.split('|');

    if (parts.length == 10) {
      final user = UserModel.fromPipeDelimited(parts);
      await StorageService.instance.saveUser(user);
      await StorageService.instance.setSiteUrl(parts[8]);
      await StorageService.instance.setCollegeName(parts[9]);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid QR Code format. Please use your SIMS QR Code.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () => _scanned = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Scan QR Code',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onQRDetected),

          // Overlay frame
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.accent, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Corner decorations
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  _corner(Alignment.topLeft),
                  _corner(Alignment.topRight),
                  _corner(Alignment.bottomLeft),
                  _corner(Alignment.bottomRight),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'Point your camera at the SIMS QR Code',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0
                ? BorderSide(color: AppTheme.primary, width: 4)
                : BorderSide.none,
            bottom: alignment.y > 0
                ? BorderSide(color: AppTheme.primary, width: 4)
                : BorderSide.none,
            left: alignment.x < 0
                ? BorderSide(color: AppTheme.primary, width: 4)
                : BorderSide.none,
            right: alignment.x > 0
                ? BorderSide(color: AppTheme.primary, width: 4)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft ? const Radius.circular(6) : Radius.zero,
            topRight: alignment == Alignment.topRight ? const Radius.circular(6) : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft ? const Radius.circular(6) : Radius.zero,
            bottomRight:
                alignment == Alignment.bottomRight ? const Radius.circular(6) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
