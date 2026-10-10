import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:smap/repository/coach_repository.dart';

class InterviewDetailScreen extends StatefulWidget {
  final Map<String, dynamic> interviewData;
  final CoachRepository repository;

  const InterviewDetailScreen({
    super.key,
    required this.interviewData,
    required this.repository,
  });

  @override
  State<InterviewDetailScreen> createState() => _InterviewDetailScreenState();
}

class _InterviewDetailScreenState extends State<InterviewDetailScreen> {
  List<Map<String, dynamic>> _notesList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
    _parseInitialNotes();
  }

  Future<void> addNewNote(String note) async {
    final Map<String, dynamic> payload = {
      "dataObj": {"interview": widget.interviewData['id'], "note": note},
    };

    try {
      final Map<String, dynamic> response = await widget.repository.addNewNote(
        payload,
      );

      if (response['success'] == true) {
        if (mounted) {
          setState(() {
            _notesList.insert(0, {
              'note': note,
              'date': DateTime.now().toIso8601String(),
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not başarıyla eklendi! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hata: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _parseInitialNotes() {
    final rawNotes =
        widget.interviewData['notes'] ?? widget.interviewData['notesStr'];

    if (rawNotes != null) {
      setState(() {
        if (rawNotes is List) {
          _notesList = rawNotes.map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{};
          }).toList();
        } else if (rawNotes is String) {
          try {
            final decoded = jsonDecode(rawNotes);
            if (decoded is List) {
              _notesList = decoded
                  .map((item) => Map<String, dynamic>.from(item as Map))
                  .toList();
            }
          } catch (e) {
            debugPrint("JSON Decode Hatası: $e");
          }
        }
      });
    }
  }

  String _formatNoteDate(String? isoDateStr) {
    if (isoDateStr == null) return '';
    try {
      DateTime parsed = DateTime.parse(isoDateStr);
      return DateFormat('d MMMM yyyy, HH:mm', 'tr_TR').format(parsed);
    } catch (e) {
      return isoDateStr;
    }
  }

  // --- GÜNCELLENEN DIYALOGLAR ---

  void _showAddNoteDialog() {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // 👈 StatefulBuilder ekledik ki diyalog içindeki buton loading durumunu anlık yakalayıp circle dönebilsin
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Yeni Not Ekle',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF162A40),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bu görüşme için yeni bir not yazın:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Yeni Görüşme notu',
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF162A40),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(
                    'İptal',
                    style: TextStyle(
                      color: _isLoading ? Colors.grey.shade400 : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF162A40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(
                      88,
                      36,
                    ), // Circle dönünce butonun büzüşmesini engeller
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (noteController.text.trim().isNotEmpty) {
                            String addedNote = noteController.text.trim();
                            // Diyalog içindeki UI'ı loading moduna geçirir
                            setDialogState(() {
                              _isLoading = true;
                            });
                            await addNewNote(addedNote);
                            if (context.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Kaydet',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditNoteDialog(int index, Map<String, dynamic> currentNote) {
    final TextEditingController noteController = TextEditingController(
      text: currentNote['note'],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Notu Düzenle',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF162A40),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Görüşme notunu güncelleyin:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF162A40),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(
                    'Vazgeç',
                    style: TextStyle(
                      color: _isLoading ? Colors.grey.shade400 : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF162A40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(88, 36),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (noteController.text.trim().isNotEmpty) {
                            final String updatedNote = noteController.text
                                .trim();

                            setDialogState(() {
                              _isLoading = true;
                            });

                            final Map<String, dynamic> payload = {
                              "dataObj": {
                                "interview": widget.interviewData['id'],
                                "note": updatedNote,
                                "editIndex": index,
                              },
                            };

                            try {
                              final response = await widget.repository.editNote(
                                payload,
                              );
                              if (response['success'] == true) {
                                if (mounted) {
                                  setState(() {
                                    _notesList[index]['note'] = updatedNote;
                                    _notesList[index]['date'] = DateTime.now()
                                        .toIso8601String();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Not başarıyla güncellendi! 🎉',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Hata: ${e.toString().replaceAll('Exception: ', '')}',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              setDialogState(() {
                                _isLoading = false;
                              });
                              if (mounted && context.mounted) {
                                Navigator.pop(dialogContext);
                              }
                            }
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Güncelle',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteNote(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Notu Sil',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bu görüşme notunu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(
                    'İptal',
                    style: TextStyle(
                      color: _isLoading ? Colors.grey.shade400 : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(88, 36),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setDialogState(() {
                            _isLoading = true;
                          });

                          final Map<String, dynamic> payload = {
                            "dataObj": {
                              "interview": widget.interviewData['id'],
                              "deleteIndex": index,
                            },
                          };

                          try {
                            final response = await widget.repository.deleteNote(
                              payload,
                            );
                            if (response['success'] == true) {
                              if (mounted) {
                                setState(() {
                                  _notesList.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Not başarıyla silindi!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Hata: ${e.toString().replaceAll('Exception: ', '')}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            setDialogState(() {
                              _isLoading = false;
                            });
                            if (mounted && context.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Sil',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String studentImage =
        widget.interviewData['studentImage']?.toString() ?? '';

    print(widget.interviewData);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70.0,
        title: const Text(
          'Görüşme Detayı',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadowMedium, blurRadius: 10),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade200,
                    child: studentImage.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image(
                              image: AssetImage("assets/avatars/$studentImage"),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  (widget.interviewData['studentName']
                                              ?.toString() ??
                                          'U')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF162A40),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                );
                              },
                              frameBuilder:
                                  (
                                    context,
                                    child,
                                    frame,
                                    wasSynchronouslyLoaded,
                                  ) {
                                    if (wasSynchronouslyLoaded) return child;
                                    return AnimatedOpacity(
                                      opacity: frame == null ? 0 : 1,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: child,
                                    );
                                  },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Color(0xFF162A40),
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.interviewData['studentName'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D2744),
                          ),
                        ),
                        if (widget.interviewData['date'] != null &&
                            widget.interviewData['date']
                                .toString()
                                .isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.interviewData['date'].toString(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '${widget.interviewData['topic']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Görüşme Notları',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2744),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddNoteDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Not Ekle'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF162A40),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _notesList.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Text(
                      'Henüz not girilmemiş.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _notesList.length,
                    itemBuilder: (context, index) {
                      final noteItem = _notesList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatNoteDate(noteItem['date']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () =>
                                          _showEditNoteDialog(index, noteItem),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteNote(index),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              noteItem['note'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
