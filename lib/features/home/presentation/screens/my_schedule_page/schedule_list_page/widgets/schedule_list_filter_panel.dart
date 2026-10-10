import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class ScheduleListFilterPanel extends StatefulWidget {
  const ScheduleListFilterPanel({
    super.key,
    required this.onApply,
    required this.onClear,
  });

  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  State<ScheduleListFilterPanel> createState() => _ScheduleListFilterPanelState();
}

class _ScheduleListFilterPanelState extends State<ScheduleListFilterPanel> {
  bool _son30Gun = false;
  bool _son3Ay = false;
  bool _buDonem = false;

  bool get _hasSelection => _son30Gun || _son3Ay || _buDonem;

  void _clear() {
    setState(() {
      _son30Gun = false;
      _son3Ay = false;
      _buDonem = false;
    });
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.menuCardBackground,
      elevation: 6,
      shadowColor: AppColors.shadowMedium,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filtrele',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _hasSelection ? _clear : null,
                  child: Text(
                    'Filtreleri Temizle',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _hasSelection
                          ? AppColors.primaryOrange
                          : AppColors.primaryOrange.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 1, color: AppColors.background),
            const SizedBox(height: 8),
            const Text(
              'Tarih aralığı',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 10),
            _dateOption(
              label: 'Son 30 Gün',
              value: _son30Gun,
              onChanged: (v) => setState(() => _son30Gun = v),
            ),
            const SizedBox(height: 4),
            _dateOption(
              label: 'Son 3 Ay',
              value: _son3Ay,
              onChanged: (v) => setState(() => _son3Ay = v),
            ),
            const SizedBox(height: 4),
            _dateOption(
              label: 'Bu Dönem',
              value: _buDonem,
              onChanged: (v) => setState(() => _buDonem = v),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: widget.onApply,
              icon: const Icon(Icons.filter_alt_outlined, size: 20),
              label: const Text(
                'Filtrele',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateOption({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                activeColor: AppColors.appBarBackground,
                checkColor: AppColors.white,
                side: const BorderSide(color: AppColors.appBarBackground, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (v) => onChanged(v ?? false),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
