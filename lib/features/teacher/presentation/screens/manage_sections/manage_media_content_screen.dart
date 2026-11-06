import 'dart:io';
import 'dart:convert'; 
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; 

class ManageMediaContentScreen extends StatefulWidget {
  final String lessonName;
  final String? initialContent;

  const ManageMediaContentScreen({
    super.key,
    required this.lessonName,
    this.initialContent,
  });

  @override
  State<ManageMediaContentScreen> createState() => _ManageMediaContentScreenState();
}

class _ManageMediaContentScreenState extends State<ManageMediaContentScreen> {
  String? _currentVideoOnServer; 
  File? _selectedVideoFile; 
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  final String _cloudName = "dq8borvfa"; 
  final String _uploadPreset = "ea7g0e9u"; 

  @override
  void initState() {
    super.initState();
    _currentVideoOnServer = widget.initialContent;
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 15),
      );

      if (pickedFile != null) {
        setState(() {
          _selectedVideoFile = File(pickedFile.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم اختيار الفيديو من المعرض بنجاح', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.primary),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء اختيار الفيديو: $e', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _uploadVideoToServer() async {
    if (_selectedVideoFile == null) return;

    setState(() => _isUploading = true);

    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/video/upload');
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', _selectedVideoFile!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        
        final String videoUrl = jsonResponse['secure_url']; 

        if (!mounted) return;
        setState(() {
          _isUploading = false;
          _currentVideoOnServer = videoUrl; 
          _selectedVideoFile = null; 
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفع الفيديو إلى Cloudinary وبثه بنجاح 🎉', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF27AE60)),
        );
        
        Navigator.pop(context, _currentVideoOnServer);
      } else {
        throw Exception("فشل الرفع، رمز الحالة: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الرفع السحابي: $e', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _deleteVideo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                SizedBox(width: 8),
                Text('تأكيد حذف الفيديو', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text('هل أنت متأكد من حذف هذا الفيديو نهائياً من السيرفر؟ لن يتمكن الطلاب من مشاهدته بعد الآن.', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.5)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (!mounted) return; 
                  setState(() {
                    _currentVideoOnServer = null; 
                    _selectedVideoFile = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف الفيديو من السيرفر', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Colors.redAccent),
                  );
                  Navigator.pop(context, '');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('نعم، احذف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = (MediaQuery.of(context).size.height * 0.20) - 20;
    
    final bool isVideoLive = _currentVideoOnServer != null && _currentVideoOnServer!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: isVideoLive ? const Color(0xFFE8F8F5) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: isVideoLive ? const Color(0xFF27AE60).withAlpha((0.3 * 255).toInt()) : Colors.grey[300]!, width: 1.5)),
                      child: Column(
                        children: [
                          Icon(isVideoLive ? Icons.check_circle_rounded : Icons.video_library_rounded, color: isVideoLive ? const Color(0xFF27AE60) : Colors.grey[400], size: 40),
                          const SizedBox(height: 12),
                          Text(isVideoLive ? 'الفيديو مرفوع ونشط على السيرفر' : 'لا يوجد فيديو مرفوع حالياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: isVideoLive ? const Color(0xFF27AE60) : Colors.grey[600])),
                          if (isVideoLive) ...[
                            const SizedBox(height: 8),
                            Text(_currentVideoOnServer!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Text('لوحة التحكم (رفع من المعرض):', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 15),
                    if (!isVideoLive) ...[
                      if (_selectedVideoFile == null) ...[
                        SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: _pickVideoFromGallery, icon: const Icon(Icons.photo_library_rounded, color: Colors.white), label: const Text('اختيار فيديو من معرض الهاتف', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0))),
                      ] else ...[
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withAlpha((0.3 * 255).toInt()))), child: Row(children: [const Icon(Icons.movie_creation_rounded, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Text(_selectedVideoFile!.path.split('/').last, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)), IconButton(icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20), onPressed: _isUploading ? null : () => setState(() => _selectedVideoFile = null))])),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: _isUploading ? null : _uploadVideoToServer, icon: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Icon(Icons.cloud_upload_rounded, color: Colors.white), label: Text(_isUploading ? 'جاري رفع الفيديو إلى Cloudinary...' : 'تأكيد رفع الفيديو للطلاب', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6A100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0))),
                      ],
                    ] else ...[
                      SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _pickVideoFromGallery, icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white), label: const Text('استبدال واختيار فيديو آخر', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005F61), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0))),
                      if (_selectedVideoFile != null) ...[
                        const SizedBox(height: 12),
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withAlpha((0.3 * 255).toInt()))), child: Row(children: [const Icon(Icons.movie_creation_rounded, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Text(_selectedVideoFile!.path.split('/').last, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis))])),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _isUploading ? null : _uploadVideoToServer, icon: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Icon(Icons.cloud_upload_rounded, color: Colors.white), label: Text(_isUploading ? 'جاري الاستبدال والرفع السحابي...' : 'تأكيد رفع الفيديو الجديد', style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6A100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0))),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(width: double.infinity, height: 50, child: OutlinedButton.icon(onPressed: _isUploading ? null : _deleteVideo, icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent), label: const Text('حذف الفيديو من السيرفر نهائياً', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.5, fontWeight: FontWeight.bold, color: Colors.redAccent)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                    ]
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0, height: headerHeight-10,
              child: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF005F61), Color(0xFF003D3F)], begin: Alignment.topRight, end: Alignment.bottomLeft)),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          onPressed: () => Navigator.pop(context, _currentVideoOnServer),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [const Text('إدارة فيديو الدرس', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), Text(widget.lessonName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis)])),
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
  }
}