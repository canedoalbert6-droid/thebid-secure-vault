import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../components/tilt_card.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool _isLoading = false;
  Offset mousePos = Offset.zero;
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (authVM.userModel != null) {
        _nameController.text = authVM.userModel!.displayName;
        if (authVM.userModel!.age != null) _ageController.text = authVM.userModel!.age.toString();
        if (authVM.userModel!.weight != null) _weightController.text = authVM.userModel!.weight.toString();
        if (authVM.userModel!.height != null) _heightController.text = authVM.userModel!.height.toString();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(AuthViewModel authVM) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final int? age = int.tryParse(_ageController.text.trim());
      final double? weight = double.tryParse(_weightController.text.trim());
      final double? height = double.tryParse(_heightController.text.trim());
      final String name = _nameController.text.trim();

      await authVM.updateName(name);

      if (authVM.user != null) {
        await FirestoreService().updateUserProfile(authVM.user!.uid, {
          'displayName': name,
          if (age != null) 'age': age,
          if (weight != null) 'weight': weight,
          if (height != null) 'height': height,
        });

        if (_imageFile != null) {
          await FirestoreService().uploadProfilePicture(authVM.user!.uid, _imageFile!);
        }

        await authVM.refreshUser();
        
        if (mounted) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Profile updated successfully!", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.easyColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            )
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception("User is not securely authenticated.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: ${e.toString()}", style: GoogleFonts.plusJakartaSans(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        )
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final isDark = themeVM.isDark;
    final size = MediaQuery.of(context).size;

    final primaryColor = const Color(0xFF4776E6);
    final secondaryColor = const Color(0xFF8E54E9);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1C1E);
    final inputColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_rounded, color: textColor, size: 20),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text("Edit Profile", style: GoogleFonts.plusJakartaSans(color: textColor, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: MouseRegion(
        onHover: (event) => setState(() => mousePos = event.localPosition),
        child: Stack(
          children: [
            _buildAnimatedBackground(size, isDark, primaryColor, secondaryColor),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: TiltCard(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppTheme.brandGradient,
                                    boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                                  ),
                                  child: CircleAvatar(
                                    radius: 54,
                                    backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                                    backgroundImage: _imageFile != null
                                        ? FileImage(_imageFile!)
                                        : (authVM.userModel?.profilePicture != null
                                            ? NetworkImage(authVM.userModel!.profilePicture!) as ImageProvider
                                            : null),
                                    child: _imageFile == null && authVM.userModel?.profilePicture == null
                                        ? Text(
                                            authVM.userModel?.displayName.substring(0, 1).toUpperCase() ?? "U",
                                            style: GoogleFonts.plusJakartaSans(fontSize: 48, color: primaryColor, fontWeight: FontWeight.w900),
                                          )
                                        : null,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(gradient: AppTheme.brandGradient, shape: BoxShape.circle, border: Border.all(color: isDark ? AppTheme.bgDark : AppTheme.bgLight, width: 4)),
                                  child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn().scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 48),
                      
                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: AppTheme.glassCard(isDark: isDark, accentColor: primaryColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("PERSONAL DETAILS", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                            const SizedBox(height: 24),
                            
                            _buildTextField("Full Name", _nameController, inputColor, textColor, Icons.person_outline_rounded, false, isRequired: true),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _buildTextField("Age", _ageController, inputColor, textColor, Icons.cake_outlined, true, isRequired: false)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField("Weight (kg)", _weightController, inputColor, textColor, Icons.monitor_weight_outlined, true, isRequired: false)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildTextField("Height (cm)", _heightController, inputColor, textColor, Icons.height_outlined, true, isRequired: false),
                          ],
                        ),
                      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 40),
                      
                      // Save Button
                      TiltCard(
                        tiltSensitivity: 0.02,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: AppTheme.brandGradient,
                            boxShadow: [
                              BoxShadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 8))
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _isLoading ? null : () => _saveChanges(authVM),
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text("Save Changes", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          ),
                        ),
                      ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size, bool isDark, Color primary, Color secondary) {
    double dx = (mousePos.dx - size.width / 2) / 50;
    double dy = (mousePos.dy - size.height / 2) / 50;

    return Stack(
      children: [
        AnimatedPositioned(
          duration: 200.ms,
          top: size.height * 0.05 + dy,
          left: size.width * 0.1 + dx,
          child: AppTheme.blob(250, isDark ? primary.withValues(alpha: 0.12) : primary.withValues(alpha: 0.06))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.9, end: 1.1, duration: 4.seconds),
        ),
        AnimatedPositioned(
          duration: 200.ms,
          bottom: size.height * 0.1 - dy,
          right: size.width * 0.05 - dx,
          child: AppTheme.blob(300, isDark ? secondary.withValues(alpha: 0.10) : secondary.withValues(alpha: 0.05))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 1.1, end: 0.9, duration: 5.seconds),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, Color fill, Color textCol, IconData icon, bool isNumber, {bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.plusJakartaSans(color: textCol, fontWeight: FontWeight.w700),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(color: textCol.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: const Color(0xFF4776E6).withValues(alpha: 0.7)),
        filled: true,
        fillColor: fill,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4776E6), width: 2)),
      ),
      validator: (val) {
        if (isRequired && (val == null || val.isEmpty)) return 'Required';
        if (val != null && val.isNotEmpty && isNumber && double.tryParse(val) == null) return 'Invalid number';
        return null;
      },
    );
  }
}
