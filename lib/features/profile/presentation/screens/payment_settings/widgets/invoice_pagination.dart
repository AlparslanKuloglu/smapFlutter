import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';

class InvoicePagination extends StatelessWidget {
  const InvoicePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(
            label: 'Geri',
            icon: Icons.chevron_left_rounded,
            enabled: currentPage > 1,
            iconAfterText: false,
            onTap: () => onPageChanged(currentPage - 1),
          ),
          const SizedBox(width: 8),
          ..._buildPageButtons(),
          const SizedBox(width: 8),
          _NavButton(
            label: 'İleri',
            icon: Icons.chevron_right_rounded,
            enabled: currentPage < totalPages,
            iconAfterText: true,
            onTap: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageButtons() {
    final items = <_PageItem>[];
    for (var page = 1; page <= totalPages; page++) {
      final showPage =
          page == 1 || page == totalPages || (page - currentPage).abs() <= 1;
      if (!showPage) {
        if (items.isEmpty || items.last.page != null) {
          items.add(const _PageItem.ellipsis());
        }
        continue;
      }
      items.add(_PageItem.page(page));
    }

    return items
        .map(
          (item) => item.page == null
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : _PageNumberButton(
                  page: item.page!,
                  isSelected: item.page == currentPage,
                  onTap: () => onPageChanged(item.page!),
                ),
        )
        .toList();
  }
}

class _PageItem {
  const _PageItem.page(this.page);
  const _PageItem.ellipsis() : page = null;
  final int? page;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.iconAfterText,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final bool iconAfterText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.textPrimary : AppColors.navUnselected;
    final children = iconAfterText
        ? [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Icon(icon, size: 20, color: color),
          ]
        : [
            Icon(icon, size: 20, color: color),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ];

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  const _PageNumberButton({
    required this.page,
    required this.isSelected,
    required this.onTap,
  });

  final int page;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
