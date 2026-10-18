import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month_rounded, size: 16, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: appState.availableMonths.contains(appState.currentMonth)
                    ? appState.currentMonth
                    : appState.availableMonths.first,
                underline: const SizedBox(),
                isDense: true,
                dropdownColor: Colors.white,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
                items: appState.availableMonths.map((month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (newMonth) {
                  if (newMonth != null) {
                    appState.changeSelectedMonth(newMonth);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Switched to billing month: $newMonth')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
