import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../---Translate---/vocabulary.dart';
import '../../---Translate---/locale_manager.dart';
import '../../config/api_config.dart';
import 'addcontinuingtreatment.dart';

class ContinuingTreatmentPage extends StatefulWidget {
  const ContinuingTreatmentPage({super.key});

  @override
  State<ContinuingTreatmentPage> createState() => _ContinuingTreatmentPageState();
}

class _ContinuingTreatmentPageState extends State<ContinuingTreatmentPage> {
  List<dynamic> treatmentList = [];
  List<dynamic> statusList = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTreatmentReminders();
    fetchStatusList();
  }

  Future<void> fetchTreatmentReminders() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.get(
        Uri.parse('${ApiConfig.remindersEndpoint}?userId=103'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // Debug: แสดงข้อมูลจาก API
        if (data.isNotEmpty) {
          print('=== TREATMENT REMINDERS DEBUG ===');
          print('Total reminders from API: ${data.length}');
          print('Sample reminder: ${data.first}');
          print('Available fields: ${data.first.keys.toList()}');
        }

        setState(() {
          treatmentList = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reminders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching treatment reminders: $e');
      setState(() {
        errorMessage = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchStatusList() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.dropdownStatusEndpoint),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          statusList = data;
        });
      }
    } catch (e) {
      // ignore error
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = localeManager.currentLocale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get('continuing_treatment', currentLanguage)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchTreatmentReminders,
            tooltip: 'รีเฟรชข้อมูล',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isDark
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(255, 176, 208, 240),
                          Color.fromARGB(255, 144, 184, 228),
                        ],
                      ),
                color: isDark ? Theme.of(context).cardColor : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    color: isDark ? Colors.white : Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.get('total_patients', currentLanguage),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${treatmentList.length} ${AppLocalizations.get('patients', currentLanguage)}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              AppLocalizations.get('patient_list', currentLanguage),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Patient list
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 80,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: fetchTreatmentReminders,
                                child: const Text('ลองใหม่'),
                              ),
                            ],
                          ),
                        )
                      : treatmentList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.medical_services_outlined,
                                    size: 80,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'ไม่มีข้อมูลการรักษาต่อเนื่อง',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: fetchTreatmentReminders,
                              child: ListView.builder(
                                itemCount: treatmentList.length,
                                itemBuilder: (context, index) {
                                  final treatment = treatmentList[index];
                                  return _buildTreatmentCard(treatment, isDark, currentLanguage);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddContinuingTreatmentPage(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 176, 208, 240),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildTreatmentCard(Map<String, dynamic> treatment, bool isDark, String currentLanguage) {
    // ปรับให้รองรับ field names จาก API
    final bool isWarning = treatment['status'] == 'warning' || treatment['urgent'] == true;
    final String patientName = treatment['userId']?.toString() ?? treatment['patient_name'] ?? treatment['patientName'] ?? 'ไม่ระบุชื่อ';
    final String treatmentName = treatment['fevertype'] ?? treatment['treatment_name'] ?? treatment['treatmentName'] ?? 'ไม่ระบุการรักษา';
    final String medication = treatment['drugName'] ?? treatment['medication'] ?? treatment['drug_name'] ?? 'ไม่ระบุยา';
    final String nextAppointment = treatment['receiveTime'] ?? treatment['next_appointment'] ?? treatment['nextAppointment'] ?? treatment['reminder_date'] ?? 'ไม่ระบุ';
    final String note = treatment['note'] ?? treatment['description'] ?? '';
    final String statusValue = treatment['status']?.toString() ?? '';
    String? statusLabel;
    if (statusValue.isNotEmpty && statusList.isNotEmpty) {
      final found = statusList.firstWhere(
        (s) => s['value'].toString() == statusValue,
        orElse: () => null,
      );
      if (found != null) statusLabel = found['label'] ?? found['value'];
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isWarning 
            ? Border.all(color: Colors.orange, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isWarning 
                        ? (isDark ? Colors.orange.shade900 : Colors.orange.shade50)
                        : (isDark ? Colors.blue.shade900 : Colors.blue.shade50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person,
                    color: isWarning ? Colors.orange : Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        treatmentName,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isWarning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.get('urgent', currentLanguage),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.get('medication', currentLanguage),
                    medication,
                    Icons.medication,
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.get('next_appointment', currentLanguage),
                    nextAppointment,
                    Icons.calendar_today,
                    isDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            if (note.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${AppLocalizations.get('note', currentLanguage)}: $note',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (statusLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: Text('สถานะ: $statusLabel', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
