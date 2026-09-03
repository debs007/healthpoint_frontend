import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../providers/auth_provider.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.requestOtp(_mobileController.text.trim());

    if (!mounted) return;

    if (success) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OtpScreen()));
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  void _socialNotConnected(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in isn\'t connected on the backend yet - mobile + OTP below works.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White now, not AppColors.primary - this single line was the
      // entire green background. No ConstrainedBox/IntrinsicHeight/
      // Expanded gymnastics needed anymore either: those existed only to
      // stop green from bleeding through gaps in a short-content scroll
      // view. With one uniform white background, any leftover space
      // below the content is already the right color by default.
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero banner - already contains the full logo, wordmark,
              // and tagline baked into the image itself.
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Image.asset(AppImages.loginHero, width: double.infinity, fit: BoxFit.contain),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Login to your account', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('+91', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0),
                          hintText: 'Enter your mobile number',
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your mobile number';
                          }
                          if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
                            return 'Enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _submit,
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Send OTP'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text('Continue with', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ),
                    const SizedBox(height: 12),

                    // Google / Apple - visually matches the design, but
                    // neither is wired to anything real: there's no OAuth
                    // integration on the backend for either. Tapping
                    // either says so directly rather than doing nothing
                    // or pretending to work.
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _socialNotConnected('Google'),
                        icon: Image.asset(AppImages.socialGoogle, width: 20, height: 20),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, side: const BorderSide(color: AppColors.border)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _socialNotConnected('Apple'),
                        icon: Image.asset(AppImages.socialApple, width: 20, height: 20),
                        label: const Text('Continue with Apple'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, side: const BorderSide(color: AppColors.border)),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _TrustBadge(image: AppImages.badgeGenuine, label: '100% Genuine\nMedicines'),
                        _TrustBadge(image: AppImages.badgeDelivery, label: 'Fast & Safe\nDelivery'),
                        _TrustBadge(image: AppImages.badgeSupport, label: '24x7 Expert\nSupport'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.image, required this.label});

  final String image;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(image, width: 28, height: 28),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
