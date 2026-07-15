import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/pages/home_page/bloc/home_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// Custom drawer widget for the home page
/// Provides navigation to interview history and account management options
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 234, 240, 249),
      child: Column(
        children: [
          // Drawer header with app branding
          _buildDrawerHeader(),

          // Main navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.history_rounded,
                  title: 'Interview History',
                  subtitle: 'View past interviews',
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    context.push('/resultHistory');
                  },
                ),
                Divider(
                  height: 24.h,
                  thickness: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                  color: Colors.black12,
                ),
              ],
            ),
          ),

          // Account section at bottom
          Divider(height: 1, thickness: 1, color: Colors.black12),
          _buildAccountSection(context),
        ],
      ),
    );
  }

  /// Builds the header section with app branding
  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3F51B5),
            const Color(0xFF3F51B5).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App icon
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    'assets/images/icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // App name
              Text(
                'Intervista AI',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              // Tagline
              Text(
                'Master your interviews',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a drawer list item with consistent styling
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 219, 226, 246),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 22.sp,
            color: iconColor ?? const Color(0xFF3F51B5),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.sp, color: Colors.black54),
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        hoverColor: Colors.black.withValues(alpha: 0.05),
      ),
    );
  }

  /// Builds the account management section
  Widget _buildAccountSection(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDrawerItem(
            context: context,
            icon: Icons.logout_rounded,
            title: 'Log out',
            subtitle: 'Sign out of your account',
            onTap: () async {
              await _confirmLogout(context);

              if (!context.mounted) return;
              context.pop();
            },
            iconColor: const Color(0xFF3F51B5),
          ),
          Divider(height: 1, thickness: 1, color: Colors.black12),
          _buildDrawerItem(
            context: context,
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account',
            subtitle: 'Submit a request to delete your account',
            onTap: () async {
              await _confirmDeleteAccountRequest(context);
              if (!context.mounted) return;
              context.pop();
            },
            iconColor: Colors.redAccent,
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  /// Shows confirmation dialog for logout
  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
          contentPadding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
          actionsPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          title: Text(
            'Log out?',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontSize: 16.sp, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 16.sp, color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              ),
              child: Text(
                'Log out',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      context.read<HomeBloc>().add(LogoutButtonClicked());
    }
  }

  /// Shows a confirmation dialog before opening the account deletion form.
  Future<void> _confirmDeleteAccountRequest(BuildContext context) async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
          contentPadding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
          actionsPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          title: Text(
            'Delete account?',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to request account deletion? You will be taken to the deletion request form.',
            style: TextStyle(fontSize: 15.sp, color: Colors.black87, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 15.sp, color: Colors.black54),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Yes, continue',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (shouldProceed != true || !context.mounted) return;

    await _launchDeleteAccountForm(context);
  }

  /// Launches the account deletion request form with graceful error handling.
  Future<void> _launchDeleteAccountForm(BuildContext context) async {
    final uri = Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLSegZQFnuoglxhOTx6_DurJk5aTQXT3XBDsM7bM5H2w5-GVx2w/viewform',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showSnackBar(
          context,
          'The deletion form could not be opened. Please try again.',
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(
        context,
        'Something went wrong while opening the form. Please try again.',
      );
    }
  }

  /// Displays a compact feedback message for the user.
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}
