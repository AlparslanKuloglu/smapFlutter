import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/home/presentation/provider/home_provider.dart';
import 'student_card.dart';
import 'package:studentmap/features/home/presentation/screens/coach_programs_screen.dart';
import 'package:studentmap/repository/coach_repository.dart';
import 'package:studentmap/features/analytics/presentation/screens/coach_analytics_screen.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/schedule_list_page/widgets/schedule_list_add_button.dart';
import 'package:studentmap/domain/models/student_model.dart';

import './add_student_dialog.dart';

class MyStudentsScreen extends StatefulWidget {
  final CoachRepository coachRepository;
  const MyStudentsScreen({super.key, required this.coachRepository});

  @override
  State<MyStudentsScreen> createState() => _MyStudentsScreenFlowScreenState();
}

class _MyStudentsScreenFlowScreenState extends State<MyStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allStudents = [];
  List<dynamic> _filteredStudents = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final homeProvider = context.watch<HomeProvider>();

    if (_searchController.text.isEmpty) {
      _allStudents = homeProvider.coachStudents;
      _filteredStudents = _allStudents;
    } else {
      _allStudents = homeProvider.coachStudents;
    }
  }

  void _filterStudents(String query) {
    setState(() {
      _filteredStudents = _allStudents
          .where(
            (student) => (student.name ?? '').toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Üst Arama Barı ve Sağdaki Ekleme Butonu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                // TextField yatayda kalan tüm boş alanı kaplar
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterStudents,
                    decoration: InputDecoration(
                      hintText: 'Öğrenci ara',
                      hintStyle: const TextStyle(
                        color: AppColors.navUnselected,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primaryOrange,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Arama barı ile buton arası boşluk
                // ÇÖZÜM: TextField'ın yüksekliğiyle (48) eşleşmesi için sarmaladık.
                // AspectRatio içeriye gömülü olduğu için kare (48x48) bir buton elde ederiz.
                SizedBox(
                  height: 48,
                  child: ScheduleListAddButton(
                    onPressed: () async {
                      // Diyaloğu açıyoruz ve kapanırken dönecek olan (pop edilen) veriyi bekliyoruz
                      final newStudentData =
                          await showDialog<Map<String, dynamic>>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AddStudentDialog(
                                repository: widget.coachRepository,
                              );
                            },
                          );

                      // Eğer öğrenci başarıyla eklenip diyalog kapatıldıysa
                      if (newStudentData != null && mounted) {
                        // Map yapısını Student modeline dönüştürüyoruz
                        // NOT: Modelinizdeki kurucu metodun adını (fromJson veya fromMap) projenize göre kontrol edin.
                        final studentModel = Student.fromJson(newStudentData);

                        context.read<HomeProvider>().addStudentToLocalList(
                          studentModel,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // 2'li Grid Öğrenci Listesi
          Expanded(
            child: _filteredStudents.isEmpty
                ? const Center(
                    child: Text(
                      'Öğrenci bulunamadı.',
                      style: TextStyle(color: AppColors.navUnselected),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                    itemCount: _filteredStudents.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      return StudentCard(
                        studentData: student,
                        onTap: () {
                          debugPrint(
                            'Seçilen Öğrenci ID: ${student.id} - ${student.name}',
                          );
                        },
                        onProgramTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeacherViewScheduleScreen(
                                studentName: student.name,
                                studentId: student.id,
                                studentImage: student.photo,
                              ),
                            ),
                          );
                        },
                        onAnalizTap: (tabIndex) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CoachAnalyticsDetailScreen(
                                studentName: student.name,
                                studentImage: student.photo,
                                studentId: student.id,
                                initialTabIndex: tabIndex,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
