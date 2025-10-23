import 'package:edzi/Widgets/appColors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BirthdayPicker extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(DateTime)? onDateSelected;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const BirthdayPicker({
    Key? key,
    required this.controller,
    this.hintText = 'Select Date',
    this.onDateSelected,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  _BirthdayPickerState createState() => _BirthdayPickerState();
}

class _BirthdayPickerState extends State<BirthdayPicker> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _initializeSelectedDate();
  }

  void _initializeSelectedDate() {
    // Initialize with current date or firstDate if constraints are available
    final now = DateTime.now();
    if (widget.firstDate != null && widget.lastDate != null) {
      _selectedDate = _isDateInRange(now, widget.firstDate!, widget.lastDate!)
          ? now
          : widget.firstDate!;
    } else {
      _selectedDate = widget.initialDate ?? now;
    }
    _constrainSelectedDate();
    widget.controller.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  bool _isDateInRange(DateTime date, DateTime firstDate, DateTime lastDate) {
    return !date.isBefore(firstDate) && !date.isAfter(lastDate);
  }

  void _constrainSelectedDate() {
    // Ensure the selected date is within the firstDate and lastDate constraints
    if (widget.firstDate != null && _selectedDate.isBefore(widget.firstDate!)) {
      _selectedDate = widget.firstDate!;
    }
    if (widget.lastDate != null && _selectedDate.isAfter(widget.lastDate!)) {
      _selectedDate = widget.firstDate!; // Default to firstDate instead of lastDate
    }
  }

  @override
  void didUpdateWidget(BirthdayPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if firstDate or lastDate changed (indicating a new academic year)
    if (oldWidget.firstDate != widget.firstDate ||
        oldWidget.lastDate != widget.lastDate) {
      setState(() {
        // Prefer current date if within range, otherwise use firstDate
        final now = DateTime.now();
        if (widget.firstDate != null && widget.lastDate != null) {
          _selectedDate = _isDateInRange(now, widget.firstDate!, widget.lastDate!)
              ? now
              : widget.firstDate!;
        } else {
          _selectedDate = widget.initialDate ?? now;
        }
        _constrainSelectedDate();
        widget.controller.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
        // Notify parent of the updated date
        if (widget.onDateSelected != null) {
          widget.onDateSelected!(_selectedDate);
        }
      });
    } else if (oldWidget.initialDate != widget.initialDate) {
      setState(() {
        // Only update if initialDate changes and is within constraints
        _selectedDate = widget.initialDate ?? _selectedDate;
        _constrainSelectedDate();
        widget.controller.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
        if (widget.onDateSelected != null) {
          widget.onDateSelected!(_selectedDate);
        }
      });
    }
  }

Future<void> _selectBirthday() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: widget.firstDate ?? DateTime(2000),
    lastDate: widget.lastDate ?? DateTime.now(),
    selectableDayPredicate: (DateTime date) => true,
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: MyColors.appcolor, // Primary highlight color
            onPrimary: Colors.white,    // Text on selected date
            onSurface: Colors.black,    // Default text color
          ),
          dialogBackgroundColor: Colors.white,
          // dialogTheme: DialogTheme(
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(16), // Rounded corners
          //   ),
          // ),
          textTheme: Theme.of(context).textTheme.copyWith(
                bodyLarge: const TextStyle(
                  fontFamily: 'AnekLatin-Light',
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                bodyMedium: const TextStyle(
                  fontFamily: 'AnekLatin-Light',
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                bodySmall: const TextStyle(
                  fontFamily: 'AnekLatin-Light',
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                ),
                titleMedium: TextStyle(
                  fontFamily: 'AnekLatin-Light',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: MyColors.appcolor,
                ),
              ),
          primaryTextTheme: Theme.of(context).primaryTextTheme.apply(
                fontFamily: 'AnekLatin-Light',
                bodyColor: Colors.black,
              ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null && picked != _selectedDate) {
    setState(() {
      _selectedDate = picked;
      widget.controller.text = DateFormat('dd/MM/yyyy').format(picked);
    });

    widget.onDateSelected?.call(picked);
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      child: TextFormField(
        controller: widget.controller,
        readOnly: true,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          fontFamily: 'AnekLatin-Light',
          height: 1.0,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF9CA3AF),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'AnekLatin-Light',
            height: 1.0,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          constraints: const BoxConstraints.tightFor(height: 40),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.calendar_today, size: 20),
              onPressed: _selectBirthday,
            ),
          ),
        ),
        onTap: _selectBirthday,
      ),
    );
  }
}