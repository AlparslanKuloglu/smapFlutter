import 'package:dio/dio.dart';
import '../domain/models/general_lessons.dart';
import '../domain/models/student_model.dart';

import '../../../../core/network/dio_client.dart';

class HomeRepository {
  final DioClient _dioClient = DioClient();

  // 1. Mevcut Ders Listesini Çeken Metot
  Future<List<GeneralLesson>> fetchGeneralLessons() async {
    try {
      final response = await _dioClient.dio.get('/ajax/getGeneralLessons');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['generalLessons'];
        return data.map((json) => GeneralLesson.fromJson(json)).toList();
      } else {
        throw Exception('Dersler alınamadı: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Ders listesi çekilirken network hatası: ${e.message}');
    }
  }

  // 2. Yeni: İstatistikleri (Bildirim Sayılarını) Çeken Metot
  Future<Map<String, dynamic>> fetchLessonsTotalMissing() async {
    try {
      // Gerçek API isteğini atıyoruz
      final response = await _dioClient.dio.get(
        '/student/getLessonsTotalMissing',
      );

      // Dio, validateStatus ayarımız sayesinde 500 altındaki hataları exception fırlatmadan getirir
      if (response.statusCode == 200) {
        final data = response.data;

        // Sunucudan gelen 'success' değerini kontrol ediyoruz
        if (data != null && data['success'] == true) {
          // lessonObj kısmını Map olarak döndürüyoruz
          return data['lessonObj'] as Map<String, dynamic>;
        } else {
          // Sunucu success: false dönerse (örn: oturum hatası veya yetki yok)
          throw Exception(data['message'] ?? 'Sunucu hata döndürdü');
        }
      } else {
        // 401, 404 gibi durumlar için
        throw Exception('Bağlantı hatası: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Ağ hataları, timeout veya bağlantı kesilmesi durumları
      throw Exception('Ağ hatası oluştu: ${e.message}');
    } catch (e) {
      // Diğer beklenmedik hatalar
      throw Exception('Beklenmedik bir hata oluştu: $e');
    }
  }

  Future<List<Student>> fetchMyStudents() async {
    try {
      final response = await _dioClient.dio.post('/coach/getMyStudents');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['students'];
        print(data);
        return data.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('Öğrenciler alınamadı: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Ders listesi çekilirken network hatası: ${e.message}');
    }
  }
}
