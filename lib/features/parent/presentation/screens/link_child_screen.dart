// lib/features/parent/presentation/screens/link_child_screen.dart
import 'package:fahem/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LinkChildScreen extends StatefulWidget {
  final Function(int) onTabSwitch; // للانتقال السلس

  const LinkChildScreen({super.key, required this.onTabSwitch});

  @override
  State<LinkChildScreen> createState() => _LinkChildScreenState();
}

class _LinkChildScreenState extends State<LinkChildScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isSearching = false;
  bool _childFound = false;

  void _searchForChild() {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك أدخل كود الربط أولاً', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSearching = true);
    FocusScope.of(context).unfocus(); 

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _childFound = true;
        });
      }
    });
  }

  void _confirmLinking() {
    // 1. إضافة الابن في الـ Cubit بالكود المُدخل
    context.read<ParentCubit>().linkChild(_codeController.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم ربط حساب الابن بنجاح! 🎉', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Color(0xFF005F61),
      ),
    );

    // 2. تصفير الحقول للعملية القادمة والانتقال للرئيسية
    setState(() {
      _childFound = false;
      _codeController.clear();
    });
    widget.onTabSwitch(0);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], end: Alignment.bottomLeft),
            ),
          ),
          title: const Text('ربط حساب ابن جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)]),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF005F61), size: 24),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'ادخل "الكود العشوائي" الذي تم توليده في حساب الطالب لربط حسابه ومزامنة التقارير.',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF1F2937), height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('أدخل الكود العشوائي للطالب:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _codeController,
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.bold),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'مثال: FAHEM-XXXX',
                  prefixIcon: const Icon(Icons.vpn_key_outlined, color: Color(0xFF005F61)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF005F61), width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),

              if (!_childFound)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchForChild,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: _isSearching
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('البحث عن الحساب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _childFound
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('تم العثور على الحساب:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.grey))),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFFEDF7F7), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF005F61).withAlpha(40))),
                            child: Row(
                              children: [
                                const CircleAvatar(radius: 24, backgroundColor: Colors.white, child: Icon(Icons.face_rounded, color: Color(0xFF005F61))),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('طالب محتمل (كود: ${_codeController.text})', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                      Text('المرحلة مجهولة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity, height: 50,
                            child: ElevatedButton(
                              onPressed: _confirmLinking,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6A100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              child: const Text('تأكيد ربط الحساب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}