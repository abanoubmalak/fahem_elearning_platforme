// lib/features/teachers/presentation/screens/chat_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final String subject;
  final String studentName;

  const ChatScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    required this.studentName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // دالة الإرسال المتوافقة مع هيكل database_seeder.dart
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    await FirebaseFirestore.instance.collection('teacher_questions').add({
      'studentId': FirebaseAuth.instance.currentUser?.uid ?? '',
      'teacherId': widget.teacherId,
      'studentName': widget.studentName,
      'question': messageText,
      'reply': '',
      'isReplied': false,
      'createdAt': FieldValue.serverTimestamp(), // 👈 حفظ الوقت بصيغة الفايربيز المباشرة
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
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
                      'معلم ${widget.subject} ',
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
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('teacher_questions')
                    .where('studentId', isEqualTo: currentUserId)
                    .where('teacherId', isEqualTo: widget.teacherId)
                    .snapshots(), // 👈 جلب مباشر بدون orderBy لتجنب الحاجة لـ Composite Index
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF005F61)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'ابدأ بطرح أسئلتك على المعلم الآن! 💬',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey[500]),
                      ),
                    );
                  }

                  // 👈 ترتيب الرسائل برمجياً في الذاكرة بناءً على الوقت لضمان دقة التسلسل
                  final messageDocs = snapshot.data!.docs;
                  messageDocs.sort((a, b) {
                    final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                    final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                    if (aTime == null || bTime == null) return 0;
                    return aTime.compareTo(bTime);
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: messageDocs.length,
                    itemBuilder: (context, index) {
                      final docData = messageDocs[index].data() as Map<String, dynamic>;
                      final Timestamp? timestamp = docData['createdAt'] as Timestamp?;
                      final String timeString = timestamp != null 
                          ? "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}" 
                          : "الآن";

                      final String questionText = docData['question'] ?? '';
                      final String replyText = docData['reply'] ?? '';
                      final bool isReplied = docData['isReplied'] ?? false;

                      // بما أن كل Doc هو (سؤال وإجابة)، نعرضهما كفقاعتين متتابعتين
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (questionText.isNotEmpty)
                            _buildMessageBubble(
                              text: questionText,
                              isMe: true, // الطالب (صاحب السؤال)
                              time: timeString,
                            ),
                          if (isReplied && replyText.isNotEmpty)
                            _buildMessageBubble(
                              text: replyText,
                              isMe: false, // المعلم (صاحب الرد)
                              time: timeString,
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, -4)),
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
                              onSubmitted: (_) => _sendMessage(),
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
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, // تم ضبط المحاذاة للغة العربية
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF005F61) : const Color(0xFFF1F5F9), 
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
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