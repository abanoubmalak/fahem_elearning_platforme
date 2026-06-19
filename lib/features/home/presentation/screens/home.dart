// lib/features/home/screens/home_screen.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:fahem/core/helpers/ui_helpers.dart';
import 'package:fahem/features/home/presentation/cubit/student_cubit.dart';
import 'package:fahem/features/home/presentation/widgets/banners_carousel.dart';
import 'package:fahem/features/home/presentation/widgets/welcome_header.dart';
import 'package:fahem/features/lessons/presentation/screens/subject_details_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/subject_card.dart';

// الاستدعاءات الأساسية لإدارة الحالة والـ Cubit
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 3; 

  @override
  void initState() {
    super.initState();
    // 👈 استدعاء دالة جلب البيانات لمرة واحدة فقط عند ولادة الشاشة لمنع الـ Infinite Loop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StudentCubit>().loadStudentDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [
              // 1. Background البانر الفيروزي
              Container(
                height: MediaQuery.of(context).size.height * 0.32, 
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF005F61), Color(0xFF003D3F)],
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
                ),
              ),

              // 2. المحتوى الأمامي مغلف بالكامل بالـ BlocBuilder لقراءة البيانات الحية 👈
              SafeArea(
                bottom: false,
                child: BlocBuilder<StudentCubit, StudentState>(
                  builder: (context, state) {
                    // أ) حالة التحميل السحابي
                    if (state is StudentLoading) {
                      return SizedBox(
                        // ملء المساحة بالكامل أسفل الترويسة الفيروزية
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF005F61), // لون الهوية الفيروزي ليكون واضحاً 👈
                                strokeWidth: 4,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'جاري مزامنة بياناتك الأكاديمية...',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF005F61),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // ب) حالة حدوث خطأ في الاتصال
                    if (state is StudentError) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Text(
                              state.message, 
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF005F61), fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }

                    // ج) حالة نجاح جلب البيانات (Loaded)
                    if (state is StudentLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // الترويسة والترحيب باسم الطالب الحقيقي 👈
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: HomeHeader(userName: state.name),
                          ),
                          const SizedBox(height: 20),

                          // بنر الإعلانات
                          const BannersCarousel(),
                          const SizedBox(height: 25),

                          // 3. كارت لوحة الإنجاز الإجمالية
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 16, offset: const Offset(0, 6)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('لوحة الإنجاز الإجمالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFFFEF6E5), borderRadius: BorderRadius.circular(10)),
                                      child: const Text('65%', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFE6A100))),
                                    ),
                                  ],
                                ),
















                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const LinearProgressIndicator(
                                    value: 0.65,
                                    backgroundColor: Color(0xFFF1F5F9),
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF005F61)),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    const Icon(Icons.emoji_events_rounded, color: Color(0xFFE6A100), size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'أنجزت 65% من منهج الأسبوع! استمر يا بطل.',
                                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 35),

                          // عنوان شبكة المواد الدراسية
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text('المواد الدراسية الحالية', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                          ),
                          const SizedBox(height: 16),

                          // 4. شبكة المواد الدراسية المفلترة حياً حسب صف الطالب (3 أو 5 مواد) 👈
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.15,
                              ),
                              itemCount: state.subjects.length,
                              itemBuilder: (context, index) {
                                final subject = state.subjects[index];
                                return GestureDetector(
                                  onTap: () {
                                    // حارس الحماية: فحص تفعيل باقة ولي الأمر لفتح المحتوى
                                    if (state.hasSubscription) {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => SubjectDetailsScreen(
                                          subjectId: subject.id,
                                          subjectTitle: subject.title,
                                          studentTerm: state.term,
                                        ),
                                      ));
                                    } else {
                                      UiHelpers.showSubscriptionPaywall(context);
                                    }
                                  },
                                  child: SubjectCard(
                                    title: subject.title,
                                    progress: subject.progress,
                                    icon: subject.icon,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              const SizedBox(height: 110), 
            ],
          ),
        ),
      ),
    );
  }
}