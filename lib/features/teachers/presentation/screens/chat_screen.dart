// lib/features/teachers/presentation/screens/chat_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/routing/routes.dart';
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

  // قائمة رسائل افتراضية حيوية لإثبات الكفاءة أمام لجنة المناقشة
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'مرحباً يا بطل، بالطبع تفضل باختيار السؤال وسأجيبك فوراً.',
      'isMe': false, // مرسلة من المدرس
      'time': '10:05 ص',
    },
    {
      'text': 'أهلاً بحضرتك يا فندم، كان عندي سؤال في الدرس الأول بخصوص المجموعة الصفرية.',
      'isMe': true, // مرسلة من الطالب (أبانوب)
      'time': '10:06 ص',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': 'الآن',
      });
    });

    _messageController.clear();
    
    // سكرول تلقائي لأسفل المحادثة فور إرسال رسالة جديدة
    Future.delayed(const Duration(milliseconds: 100), () {
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
      // ==================== 1. شريط علوي ذكي يحمل بيانات المعلم وحالته ====================
      appBar: AppBar(
        backgroundColor: const Color(0xFF005F61), // اللون الفيروزي الموحد للهوية
        elevation: 0,
        automaticallyImplyLeading: false, // إلغاء السهم الافتراضي لتخصيصه عربيًا
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                onPressed: () {
                  // العودة للشاشة السابقة (MainWrapper) والحفاظ على البار السفلي نشطاً
                  Navigator.pop(context);
                },
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
            // ==================== 2. منطقة عرض الرسائل القابلة للتمرير ====================
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(
                    text: message['text'],
                    isMe: message['isMe'],
                    time: message['time'],
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
                  BoxShadow(
                    color: Colors.black.withAlpha((0.03 * 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // صندوق الإدخال النصي
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
                            ),
                          ),
                          const Icon(Icons.attach_file_rounded, color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // زر الإرسال الدائري المعتمد تكنولوجياً باللون الذهبي المميز للتفاعل
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

  // ويدجت هندسة كبسولة الرسالة (Message Bubble) ومحمية بالكامل من الـ Overflow
  Widget _buildMessageBubble({required String text, required bool isMe, required String time}) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF005F61) : const Color(0xFFF1F5F9), // الفيروزي للطالب، والرمادي الفاتح للمدرس
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
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                color: isMe ? Colors.white : AppColors.textMain,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 9,
                color: isMe ? Colors.white70 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}