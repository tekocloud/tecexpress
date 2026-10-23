import 'package:flutter/material.dart';

int txCompare(Object? a, Object? b) {
  if (a == null) return b == null ? 0 : -1;
  if (b == null) return 1;
  if (a is num && b is num) return a.compareTo(b);
  final parts = RegExp(r'\d+|\D+');
  final left = parts.allMatches('$a'.toLowerCase()).map((m) => m[0]!).toList();
  final right = parts.allMatches('$b'.toLowerCase()).map((m) => m[0]!).toList();
  for (var i = 0; i < left.length && i < right.length; i++) {
    final x = num.tryParse(left[i]), y = num.tryParse(right[i]);
    final result = x != null && y != null
        ? x.compareTo(y)
        : left[i].compareTo(right[i]);
    if (result != 0) return result;
  }
  return left.length.compareTo(right.length);
}

class TxPager extends StatelessWidget {
  const TxPager({
    super.key,
    required this.page,
    required this.pageCount,
    required this.countText,
    required this.onChanged,
    this.disabled = false,
  });
  final int page, pageCount;
  final String countText;
  final ValueChanged<int> onChanged;
  final bool disabled;
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 16,
    runSpacing: 8,
    children: [
      Text(countText, style: Theme.of(context).textTheme.bodySmall),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Vorherige Seite',
            onPressed: disabled || page <= 0 ? null : () => onChanged(page - 1),
            icon: const Icon(Icons.arrow_back, size: 18),
          ),
          Text('Seite ${page + 1} / $pageCount'),
          IconButton(
            tooltip: 'Nächste Seite',
            onPressed: disabled || page >= pageCount - 1
                ? null
                : () => onChanged(page + 1),
            icon: const Icon(Icons.arrow_forward, size: 18),
          ),
        ],
      ),
    ],
  );
}
