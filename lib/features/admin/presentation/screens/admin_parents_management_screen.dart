import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:fahem/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminParentsManagementScreen extends StatefulWidget {
  const AdminParentsManagementScreen({super.key});
  @override State<AdminParentsManagementScreen> createState() => _AdminParentsManagementScreenState();
}

class _AdminParentsManagementScreenState extends State<AdminParentsManagementScreen> {
  String _searchQuery = '';

  void _openAddParentBottomSheet() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController(); 
    bool obscurePassword = true; 

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 25, 20, MediaQuery.of(context).viewInsets.bottom + 25),
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('إضافة ولي أمر جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'الاسم بالكامل', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                
                TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),

                TextField(
                  controller: passwordController, 
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور', 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: const Color(0xFF27AE60)),
                      onPressed: () => setModalState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                      BlocProvider.of<AdminCubit>(this.context).addParent({
                        'name': nameController.text.trim(), 
                        'email': emailController.text.trim(), 
                        'password': passwordController.text, 
                        'isActive': true, 
                        'linkedStudents': []
                      });
                      if (!mounted) return;
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء جميع الحقول', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('إنشاء الحساب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.22;

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        List<Map<String, dynamic>> parents = [];
        if (state is AdminLoaded) {
          parents = state.parents.where((p) => (p['name'] ?? '').toString().contains(_searchQuery) || (p['email'] ?? '').toString().contains(_searchQuery)).toList();
        }

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: [
                Positioned.fill(
                  child: parents.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 100),
                          itemCount: parents.length,
                          itemBuilder: (context, index) {
                            final parent = parents[index];
                            final bool isActive = parent['isActive'] ?? false;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                              child: Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  onTap: () => Navigator.pushNamed(context, Routes.ParentDetailsScreen, arguments: parent),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  leading: CircleAvatar(
                                    backgroundColor: isActive ? const Color(0xFFEAFAF1) : const Color(0xFFFFEAEA), 
                                    child: Icon(Icons.family_restroom_rounded, color: isActive ? const Color(0xFF27AE60) : Colors.redAccent)
                                  ),
                                  title: Text(parent['name'] ?? 'بدون اسم', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                  subtitle: Text(parent['email'] ?? 'بدون بريد', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey)),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Positioned(
                  top: 0, left: 0, right: 0, height: headerHeight,
                  child: Container(
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35))),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('إدارة أولياء الأمور', style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 16),
                            TextField(onChanged: (val) => setState(() => _searchQuery = val), decoration: InputDecoration(hintText: 'ابحث بالاسم أو البريد...', hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 14), prefixIcon: const Icon(Icons.search, color: Colors.grey), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300), const SizedBox(height: 16), Text('لم يتم العثور على أولياء أمور', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.bold))]));
  }
}