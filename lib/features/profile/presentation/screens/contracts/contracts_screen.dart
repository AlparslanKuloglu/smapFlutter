import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/domain/models/legal_document.dart';
import 'package:smap/features/auth/domain/usecases/get_legal_documents_usecase.dart';
import 'package:smap/features/profile/presentation/screens/contracts/widgets/contract_card.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen({super.key});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  List<LegalDocument> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Sayfa çizildikten hemen sonra isteği atıyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchContracts();
    });
  }

  Future<void> _fetchContracts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final useCase = context.read<GetLegalDocumentsUseCase>();
      final docs = await useCase();

      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Sözleşmeler yüklenirken bir hata oluştu.';
        _isLoading = false;
      });
    }
  }

  void _showContractDetailDialog(LegalDocument doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 24.0,
        ),
        title: Text(
          doc.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SizedBox(
          width: MediaQuery.of(
            context,
          ).size.width, // 👈 Ekranın tam genişliğini almasını sağlar
          child: SingleChildScrollView(child: Html(data: doc.content)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.appBarBackground,
            ),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: AppColors.background, child: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchContracts,
              child: const Text('Tekrar Deneyin'),
            ),
          ],
        ),
      );
    }

    if (_documents.isEmpty) {
      return const Center(child: Text('Gösterilecek sözleşme bulunamadı.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final doc = _documents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () => _showContractDetailDialog(doc),
            child: ContractCard(
              title: doc.title,
              isApproved: doc.isActive,
              onApprovedChanged: (value) {
                // Sözleşme onay/durum değişikliği yapılacaksa buraya eklenebilir
              },
            ),
          ),
        );
      },
    );
  }
}
