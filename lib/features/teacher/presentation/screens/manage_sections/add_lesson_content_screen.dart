import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class AddLessonContentScreen extends StatefulWidget {
  final String lessonName;
  final String contentType; 

  const AddLessonContentScreen({
    super.key,
    required this.lessonName,
    required this.contentType,
  });

  @override
  State<AddLessonContentScreen> createState() => _AddLessonContentScreenState();
}

class _AddLessonContentScreenState extends State<AddLessonContentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController; 

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController(
      text: widget.contentType == 'video' 
          ? 'https://www.youtube.com/watch?v=fahem_math_1' 
          : 'في هذا الدرس، نتعلم التعبير الرمزي عن الدالة وكيفية تحديد المجال والمجال المقابل برمجياً.'
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveContent() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ وتحديث محتوى الدرس بنجاح وبثه حياً للطالب 🎉', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context, _contentController.text.trim()); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).size.height * 0.20;
    final bool isVideo = widget.contentType == 'video';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      resizeToAvoidBottomInset: true, 
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isVideo ? 'تحديث فيديو الشرح' : 'تحديث الملخص النصي',
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                widget.lessonName,
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Text('العنوان الرئيسي للمحتوى:', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5),
                        validator: (value) => value!.isEmpty ? 'برجاء كتابة عنوان المحتوى' : null,
                        decoration: InputDecoration(
                          hintText: isVideo ? 'مثال: شرح مقدمة العلاقات والدوال' : 'مثال: خلاصة القوانين الذهبية للدرس',
                          hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary)),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Text(
                          isVideo ? 'رابط السيرفر المستضاف (YouTube URL):' : 'نص الملخص الأكاديمي المباشر:',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                      
                      TextFormField(
                        controller: _contentController,
                        maxLines: isVideo ? 1 : 8, 
                        keyboardType: isVideo ? TextInputType.url : TextInputType.multiline,
                        style: TextStyle(
                          fontFamily: isVideo ? 'Montserrat' : 'Cairo',
                          fontSize: 13.5, 
                          height: 1.5, 
                          color: AppColors.textMain,
                        ),
                        validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب ولا يمكن تركه فارغاً' : null,
                        decoration: InputDecoration(
                          prefixIcon: isVideo ? const Icon(Icons.link_rounded, color: Color(0xFF005F61), size: 20) : null,
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary)),
                        ),
                      ),

                      const SizedBox(height: 35),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _saveContent,
                          icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
                          label: const Text('حفظ ونشر التعديلات الحالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005F61),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
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
      ),
    );
  }
}