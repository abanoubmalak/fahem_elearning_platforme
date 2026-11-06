import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fahem/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  String _selectedStage = 'الصف الأول الإعدادي';
  String _selectedSemester = 'الترم الثاني';

  final List<String> _stages = [
    'الصف الأول الابتدائي',
    'الصف الثاني الابتدائي',
    'الصف الثالث الابتدائي',
    'الصف الرابع الابتدائي',
    'الصف الخامس الابتدائي',
    'الصف السادس الابتدائي',
    'الصف الأول الإعدادي',
    'الصف الثاني الإعدادي',
    'الصف الثالث الإعدادي',
  ];

  final List<String> _semesters = ['الترم الأول', 'الترم الثاني'];

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.22;
    final double bottomSafeInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthOTPSent) {
              Navigator.pushNamed(
                context,
                Routes.OtpVerificationScreen,
                arguments: {'uid': state.uid, 'email': state.email},
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error, style: const TextStyle(fontFamily: 'Cairo')),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            final bool isLoading = state is AuthLoading;

            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: headerHeight,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: const SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تخصيص نوع الحساب',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'خطوة واحدة تفصلنا عن تجهيز واجهتك التعليمية الذكية',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, headerHeight + 25, 20, 30 + bottomSafeInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'من أنت؟ اختر طبيعة دورك الحالي:',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
                          ),
                        ),
                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Expanded(
                              child: _buildRoleCard(
                                roleValue: 'student',
                                title: 'أنا طالب',
                                subtitle: 'أريد مشاهدة الدروس وحل الاختبارات المفيدة',
                                icon: Icons.school_rounded,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildRoleCard(
                                roleValue: 'parent',
                                title: 'أنا ولي أمر',
                                subtitle: 'أريد متابعة أداء ابني ومستويات تحصيله الكلية',
                                icon: Icons.supervisor_account_rounded,
                              ),
                            ),
                          ],
                        ),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: _selectedRole == 'student'
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 30),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        'حدد خطتك الدراسية الحالية:',
                                        style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: AppColors.commonShadow,
                                      ),
                                      child: Column(
                                        children: [
                                          _buildDropdownField(
                                            label: 'الصف الدراسي الحالي',
                                            value: _selectedStage,
                                            items: _stages,
                                            onChanged: (val) => setState(() => _selectedStage = val!),
                                          ),
                                          const SizedBox(height: 15),
                                          _buildDropdownField(
                                            label: 'الفصل الدراسي',
                                            value: _selectedSemester,
                                            items: _semesters,
                                            icon: Icons.calendar_today_outlined,
                                            onChanged: (val) => setState(() => _selectedSemester = val!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(), 
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_selectedRole == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('من فضلك حدد طبيعة حسابك أولاً', style: TextStyle(fontFamily: 'Cairo')),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }
                                    context.read<AuthCubit>().completeRegistration(
                                          role: _selectedRole!,
                                          grade: _selectedRole == 'student' ? _selectedStage : null,
                                          term: _selectedRole == 'student' ? _selectedSemester : null,
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005F61),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'تأكيد الملف والدخول',
                                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleValue,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _selectedRole == roleValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = roleValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        height: 165,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDF7F7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? null : AppColors.commonShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
              child: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF005F61), size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : AppColors.textMain),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.grey[500], height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData icon = Icons.school_outlined,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold)),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF005F61), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[100]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }
}