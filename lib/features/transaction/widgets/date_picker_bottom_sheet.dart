import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DatePickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const DatePickerBottomSheet({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Calendar header with month/year and navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                ),
                Text(
                  '${_getMonthName(_displayedMonth.month)} ${_displayedMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_forward, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Day headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => SizedBox(
                        width: 40,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Calendar grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCalendarGrid(),
            ),
          ),
          
          // Done button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => widget.onDateSelected(_selectedDate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = _displayedMonth;
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final daysInMonth = lastDayOfMonth.day;
    
    // Get previous month's trailing days
    final daysInPreviousMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 0).day;
    
    List<Widget> dayWidgets = [];
    
    // Add trailing days from previous month
    for (int i = firstWeekday - 1; i >= 0; i--) {
      dayWidgets.add(_buildDayCell(
        daysInPreviousMonth - i,
        isCurrentMonth: false,
        isRed: false,
      ));
    }
    
    // Add days of current month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final isSunday = date.weekday == 7;
      
      dayWidgets.add(_buildDayCell(
        day,
        date: date,
        isCurrentMonth: true,
        isRed: isSunday,
      ));
    }
    
    // Add leading days from next month
    final remainingCells = (7 - (dayWidgets.length % 7)) % 7;
    for (int i = 1; i <= remainingCells; i++) {
      dayWidgets.add(_buildDayCell(
        i,
        isCurrentMonth: false,
        isRed: false,
      ));
    }
    
    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(int day, {DateTime? date, bool isCurrentMonth = true, bool isRed = false}) {
    final isSelected = date != null && 
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
    
    // Check if the date is in the future
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isFuture = date != null && date.isAfter(today);
    
    return GestureDetector(
      onTap: isCurrentMonth && date != null && !isFuture
          ? () {
              setState(() {
                _selectedDate = date;
              });
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : isFuture
                      ? Colors.grey.shade300
                      : isRed && isCurrentMonth
                          ? Colors.red
                          : isCurrentMonth
                              ? Colors.black
                              : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }
}
