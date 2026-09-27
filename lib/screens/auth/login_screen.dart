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

                    const SizedBox(height: 28),

                    // Replaces what used to be two non-functional social
                    // login buttons (no OAuth integration existed on the
                    // backend for either) - a feature highlight instead,
                    // covering different ground than the trust badges
                    // below rather than repeating them.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Everything for your health, in one place',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          const _FeatureRow(icon: Icons.local_pharmacy_outlined, text: 'Order medicines in minutes, delivered to your door'),
                          const SizedBox(height: 12),
                          const _FeatureRow(icon: Icons.science_outlined, text: 'Book lab tests and doctor consultations'),
                          const SizedBox(height: 12),
                          const _FeatureRow(icon: Icons.folder_shared_outlined, text: 'Keep your family\'s health records in one place'),
                        ],
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

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3)),
          ),
        ),
      ],
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
