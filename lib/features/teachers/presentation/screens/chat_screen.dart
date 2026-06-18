// lib/features/teachers/presentation/screens/chat_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String teacherName;
  final String subject;

  const ChatScreen({
    super.key,
    required this.teacherName,
    required this.subject,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // معرف ثابت وموحد للغرفة (مثال مبسط لمشروع التخرج يربط الطالب الحالي بالمعلم)
  // في التطبيق الفعلي يفضل استخدام الـ uid الخاص بالطالب
  final String _studentId = "abanoub_student"; 
  late String _chatRoomId;

  @override
  void initState() {
    super.initState();
    // إنشاء معرف فريد لغرفة المحادثة يجمع المعلم والطالب معاً منعاً لتداخل المحادثات
    _chatRoomId = "${_studentId}_${widget.teacherName.replaceAll(' ', '_')}";
  }

  // دالة إرسال الرسالة وحفظها في الفايربيز حياً
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // إضافة الرسالة في كوليكشن فرعي داخل غرفة المحادثة
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatRoomId)
        .collection('messages')
        .add({
      'text': messageText,
      'isMe': true, // الطالب هو الراسل في تطبيقه الحالي
      'timestamp': FieldValue.serverTimestamp(), // اعتماد وقت السيرفر لترتيب الرسائل بدقة
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // ==================== 1. شريط علوي يحمل بيانات المعلم وحالته ====================
      appBar: AppBar(
        backgroundColor: const Color(0xFF005F61),
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.teacherName,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'معلم ${widget.subject} • نشط الآن',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ==================== 2. منطقة عرض الرسائل الحية من الفايربيز ====================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(_chatRoomId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false) // ترتيب تصاعدي لعرض المحادثة منطقياً
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF005F61)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'ابدأ المحادثة الآن مع معلمك المتميز! 💬',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey[500]),
                      ),
                    );
                  }

                  final messageDocs = snapshot.data!.docs;
                  
                  // عمل سكرول تلقائي لآخر المحادثة فور وصول بيانات جديدة
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: messageDocs.length,
                    itemBuilder: (context, index) {
                      final docData = messageDocs[index].data() as Map<String, dynamic>;
                      
                      // معالجة الوقت والتاريخ لتجنب مشاكل الـ Null قبل وصول الـ Timestamp من السيرفر
                      final Timestamp? timestamp = docData['timestamp'] as Timestamp?;
                      final String timeString = timestamp != null 
                          ? "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}" 
                          : "الآن";

                      return _buildMessageBubble(
                        text: docData['text'] ?? '',
                        isMe: docData['isMe'] ?? true,
                        time: timeString,
                      );
                    },
                  );
                },
              ),
            ),

            // ==================== 3. شريط إدخال الرسائل السفلي الراقي ====================
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha((0.03 * 255).toInt()), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.grey, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textMain),
                              decoration: const InputDecoration(
                                hintText: 'اكتب رسالتك هنا...',
                                hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onSubmitted: (_) => _sendMessage(), // إمكانية الإرسال عبر زر الكيبورد
                            ),
                          ),
                          const Icon(Icons.attach_file_rounded, color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFE6A100),
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble({required String text, required bool isMe, required String time}) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF005F61) : const Color(0xFFF1F5F9), 
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? Radius.zero : const Radius.circular(16),
            bottomRight: isMe ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13.5, color: isMe ? Colors.white : AppColors.textMain, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: isMe ? Colors.white70 : Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}