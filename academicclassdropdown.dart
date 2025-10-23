import 'package:edzi/Widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AcademicClassDropdowns extends StatefulWidget {
  final String staffId;
  final ValueChanged<String?> onAcademicYearChanged;
  final ValueChanged<String?> onClassSectionChanged;
  final String? initialAcademicYear;
  final String? initialClassSection;

  const AcademicClassDropdowns({
    Key? key,
    required this.staffId,
    required this.onAcademicYearChanged,
    required this.onClassSectionChanged,
    this.initialAcademicYear,
    this.initialClassSection,
  }) : super(key: key);

  @override
  State<AcademicClassDropdowns> createState() => _AcademicClassDropdownsState();
}

class _AcademicClassDropdownsState extends State<AcademicClassDropdowns> {
  final ValueNotifier<String?> _academicYearNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _classSectionNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);

  Map<String, String> _academicYears = {};
  List<Map<String, dynamic>> _classSections = [];
  Map<String, Map<String, dynamic>> _classSectionMap = {};
  String? _defaultAcademicYearId;

  @override
  void initState() {
    super.initState();
    _academicYearNotifier.value = widget.initialAcademicYear;
    _classSectionNotifier.value = widget.initialClassSection;

    _loadSavedPreferences().then((_) {
      _fetchAcademicYears().then((_) {
        if (_academicYearNotifier.value != null) {
          _fetchClassSections();
        }
      });
    });
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (widget.initialAcademicYear == null) {
      final savedAcademicYear = prefs.getString('last_academic_year');
      if (savedAcademicYear != null) {
        _academicYearNotifier.value = savedAcademicYear;
        widget.onAcademicYearChanged(savedAcademicYear);
      }
    }

    if (widget.initialClassSection == null) {
      final savedClassSection = prefs.getString('last_class_section');
      if (savedClassSection != null) {
        _classSectionNotifier.value = savedClassSection;
        widget.onClassSectionChanged(savedClassSection);
      }
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (_academicYearNotifier.value != null) {
      await prefs.setString('last_academic_year', _academicYearNotifier.value!);
    }

    if (_classSectionNotifier.value != null) {
      await prefs.setString('last_class_section', _classSectionNotifier.value!);
    }
  }

  Future<String?> _getDefaultAcademicYearId() async {
    try {
      final appDefaultsDoc = await FirebaseFirestore.instance
          .collection('appdefaults')
          .doc('academic-year')
          .get();

      if (appDefaultsDoc.exists) {
        final data = appDefaultsDoc.data();
        final defaultAcademicYear = data?['academic-year'] as String?;
        
        if (defaultAcademicYear != null) {
          final matchingEntry = _academicYears.entries
              .firstWhere(
                (entry) => entry.value == defaultAcademicYear,
                orElse: () => const MapEntry('', ''),
              );
          
          if (matchingEntry.key.isNotEmpty) {
            return matchingEntry.key;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching default academic year: $e');
    }
    
    return null;
  }

  Future<void> _fetchAcademicYears() async {
    _isLoadingNotifier.value = true;
    try {
      final query = await FirebaseFirestore.instance.collection('academic-years').get();
      setState(() {
        _academicYears = {
          for (var doc in query.docs) doc.id: doc.data()['year'] ?? 'No Year',
        };
      });

      _defaultAcademicYearId = await _getDefaultAcademicYearId();

      if (_academicYearNotifier.value == null && _academicYears.isNotEmpty) {
        final selectedYearId = _defaultAcademicYearId ?? _academicYears.keys.first;
        _handleAcademicYearChange(selectedYearId);
      }
    } catch (e) {
      debugPrint('Error fetching academic years: $e');
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  Future<void> _fetchClassSections({bool preserveSelection = false}) async {
    if (_academicYearNotifier.value == null) return;

    _isLoadingNotifier.value = true;
    try {
      // Filter staff-subject-links by both staffId AND academicYear
      final staffSubjectLinks = await FirebaseFirestore.instance
          .collection('staff-subject-links')
          .where('staffId', isEqualTo: widget.staffId)
          .where('academicYear', isEqualTo: _academicYearNotifier.value)
          .get();

      if (staffSubjectLinks.docs.isEmpty) {
        setState(() {
          _classSections = [];
          _classSectionMap = {};
          if (!preserveSelection) {
            _classSectionNotifier.value = null;
            widget.onClassSectionChanged(null);
          }
        });
        return;
      }

      final classSectionSet = <String>{};

      for (var doc in staffSubjectLinks.docs) {
        final data = doc.data();
        final classId = data['classId'] as String?;
        final sectionGroupId = data['sectionGroupId'] as String?;

        if (classId != null && sectionGroupId != null) {
          final id = '${classId}_$sectionGroupId';
          classSectionSet.add(id);
        }
      }

      if (classSectionSet.isEmpty) {
        setState(() {
          _classSections = [];
          _classSectionMap = {};
          if (!preserveSelection) {
            _classSectionNotifier.value = null;
            widget.onClassSectionChanged(null);
          }
        });
        return;
      }

      final classesSnapshot = await FirebaseFirestore.instance.collection('classes').get();
      final sectionGroupsSnapshot = await FirebaseFirestore.instance.collection('section-groups').get();

      final classNames = {
        for (var doc in classesSnapshot.docs) doc.id: doc.data()['name'] ?? 'No Class',
      };

      final sectionNames = {
        for (var doc in sectionGroupsSnapshot.docs) doc.id: doc.data()['name'] ?? 'No Section',
      };

      final classSectionsList = classSectionSet.map((id) {
        final parts = id.split('_');
        final classId = parts[0];
        final sectionGroupId = parts[1];
        final className = classNames[classId] ?? 'Unknown';
        final sectionName = sectionNames[sectionGroupId] ?? 'Unknown';

        return {
          'id': id,
          'displayName': '$className-$sectionName',
          'classId': classId,
          'sectionId': sectionGroupId,
        };
      }).toList();

      classSectionsList.sort((a, b) => (a['displayName'] as String).compareTo(b['displayName'] as String));

      setState(() {
        _classSections = classSectionsList;
        _classSectionMap = {
          for (var section in classSectionsList) section['id'] as String: section,
        };

        // Check if the current selection is still valid
        if (_classSectionNotifier.value != null &&
            !_classSectionMap.containsKey(_classSectionNotifier.value)) {
          _classSectionNotifier.value = null;
          widget.onClassSectionChanged(null);
        }
      });
    } catch (e) {
      debugPrint('Error fetching class sections: $e');
      setState(() {
        _classSections = [];
        _classSectionMap = {};
        if (!preserveSelection) {
          _classSectionNotifier.value = null;
          widget.onClassSectionChanged(null);
        }
      });
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  void _handleAcademicYearChange(String? newValue) {
   
    _academicYearNotifier.value = newValue;
    widget.onAcademicYearChanged(newValue);
    
    // Always fetch class sections when academic year changes
    // since they need to be filtered by the new academic year
    _fetchClassSections(preserveSelection: false);
    
    _savePreferences();
  }

  void _handleClassSectionChange(String? newValue) {
    _classSectionNotifier.value = newValue;
    widget.onClassSectionChanged(newValue);
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<String?>(
                valueListenable: _academicYearNotifier,
                builder: (context, value, child) {
                  return CustomDropdown<String>(
                    label: 'Academic Year',
                    hint: '--Select--',
                    value: value,
                    fillColor: Colors.white,
                    items: _academicYears.keys.toList(),
                    onChanged: _handleAcademicYearChange,
                    itemBuilder: (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(_academicYears[item] ?? ''),
                    ),
                    isMandatory: true,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ValueListenableBuilder<String?>(
                valueListenable: _classSectionNotifier,
                builder: (context, classSectionValue, child) {
                  final validValue = classSectionValue != null &&
                          _classSectionMap.containsKey(classSectionValue)
                      ? classSectionValue
                      : null;

                  final classSectionIds = _classSections.map((section) => section['id'] as String).toList();

                  return CustomDropdown<String>(
                    label: 'Class Section',
                    hint: '--Select--',
                    value: validValue,
                    fillColor: Colors.white,
                    items: classSectionIds,
                    onChanged: _handleClassSectionChange,
                    itemBuilder: (item) {
                      final section = _classSectionMap[item] ?? {'displayName': 'Unknown'};
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(section['displayName'] as String),
                      );
                    },
                    isMandatory: true,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _academicYearNotifier.dispose();
    _classSectionNotifier.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }
}