// lib/features/admin/presentation/screens/students/admin_students_management_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
import 'package:flutter/material.dart';

class AdminStudentsManagementScreen extends StatefulWidget {
  const AdminStudentsManagementScreen({super.key});

  @override
  State<AdminStudentsManagementScreen> createState() => _AdminStudentsManagementScreenState();
}

class _AdminStudentsManagementScreenState extends State<AdminStudentsManagementScreen> {
  // ── بيانات محاكاة للطلاب (Mock Data) ──
  final List<Map<String, dynamic>> _allStudents = [
    {'id': '1', 'name': 'محمود أحمد', 'stage': 'الصف الثالث الإعدادي', 'phone': '01012345678', 'isActive': true},
    {'id': '2', 'name': 'سارة محمد', 'stage': 'الصف الأول الثانوي', 'phone': '01123456789', 'isActive': true},
    {'id': '3', 'name': 'علي حسن', 'stage': 'الصف الثاني الثانوي', 'phone': '01234567890', 'isActive': false},
    {'id': '4', 'name': 'ياسمين طارق', 'stage': 'الصف الثالث الثانوي', 'phone': '01534567891', 'isActive': true},
  ];

  // ── قائمة البحث ──
  List<Map<String, dynamic>> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStudents = _allStudents;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── دالة البحث ──
  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _allStudents;
      } else {
        _filteredStudents = _allStudents.where((student) {
          final name = student['name'].toString().toLowerCase();
          final phone = student['phone'].toString();
          return name.contains(query) || phone.contains(query);
        }).toList();
      }
    });
  }

  // ── دالة تغيير حالة الطالب ──
  void _toggleStudentStatus(int index) {
    setState(() {
      _filteredStudents[index]['isActive'] = !_filteredStudents[index]['isActive'];
      // TODO: تحديث الحالة في الـ API
    });
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.16;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // ── محتوى الشاشة ──
            Positioned.fill(
              child: Column(
                children: [
                  SizedBox(height: headerHeight + 20),
                  
                  // شريط البحث
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontFamily: 'Cairo'),
                      decoration: InputDecoration(
                        hintText: 'ابحث باسم الطالب أو رقم الهاتف...',
                        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF005F61)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF005F61), width: 1.5)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // قائمة الطلاب
                  Expanded(
                    child: _filteredStudents.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                            itemCount: _filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = _filteredStudents[index];
                              return _buildStudentCard(student, index);
                            },
                          ),
                  ),
                ],
              ),
            ),

            // ── الهيدر الموحد ──
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  // borderRadius: BorderRadius.only(
                  //   bottomLeft: Radius.circular(30),
                  //   bottomRight: Radius.circular(30),
                  // ),
                ),
                child: const SafeArea(
                  child: Center(
                    child: Text(
                      'إدارة الطلاب',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── كارت عرض بيانات الطالب ──
  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    final bool isActive = student['isActive'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.02 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, Routes.StudentDetailsScreen);
            
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // الصورة الرمزية
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFEDF7F7),
                  child: Text(
                    student['name'].substring(0, 1),
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF005F61)),
                  ),
                ),
                const SizedBox(width: 14),
                // تفاصيل الطالب
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.school_rounded, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              student['stage'],
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // التحكم في الحالة (حظر / تفعيل)
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── شاشة فارغة في حالة عدم وجود نتائج ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'لم يتم العثور على طلاب',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}