import 'package:flutter/material.dart';
import '../---Translate---/vocabulary.dart';
import '../---Translate---/locale_manager.dart';

class ContinuingTreatmentPage extends StatefulWidget {
  const ContinuingTreatmentPage({super.key});

  @override
  State<ContinuingTreatmentPage> createState() => _ContinuingTreatmentPageState();
}

class _ContinuingTreatmentPageState extends State<ContinuingTreatmentPage> {
  // ข้อมูลตัวอย่างผู้ป่วยที่อยู่ในการรักษาต่อเนื่อง
  final List<Map<String, dynamic>> treatmentList = [
    {
      'id': 1,
      'patientName': 'นายสมชาย ใจดี',
      'treatmentName': 'การรักษาความดันโลหิตสูง',
      'startDate': '15/06/2025',
      'nextAppointment': '15/08/2025',
      'medication': 'Amlodipine 5mg',
      'status': 'active',
      'note': 'ติดตามอาการทุก 2 เดือน'
    },
    {
      'id': 2,
      'patientName': 'นางสาวสมใส จริงใจ',
      'treatmentName': 'การรักษาเบาหวาน',
      'startDate': '20/05/2025',
      'nextAppointment': '20/08/2025',
      'medication': 'Metformin 500mg',
      'status': 'active',
      'note': 'ตรวจน้ำตาลในเลือดทุกเดือน'
    },
    {
      'id': 3,
      'patientName': 'นายประยุทธ สุขใจ',
      'treatmentName': 'การรักษาโรคหัวใจ',
      'startDate': '10/04/2025',
      'nextAppointment': '25/07/2025',
      'medication': 'Atenolol 50mg',
      'status': 'warning',
      'note': 'ใกล้ถึงนัดหมาย'
    },
    {
      'id': 4,
      'patientName': 'นางสุดา มีสุข',
      'treatmentName': 'การรักษาไทรอยด์',
      'startDate': '01/03/2025',
      'nextAppointment': '01/09/2025',
      'medication': 'Levothyroxine 75mcg',
      'status': 'active',
      'note': 'รับประทานยาตอนเช้าก่อนอาหาร'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentLanguage = localeManager.currentLocale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get('continuing_treatment', currentLanguage)),
        centerTitle: true,
        elevation: 0,
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
              child: ListView.builder(
                itemCount: treatmentList.length,
                itemBuilder: (context, index) {
                  final treatment = treatmentList[index];
                  return _buildTreatmentCard(treatment, isDark, currentLanguage);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new patient treatment
        },
        backgroundColor: const Color.fromARGB(255, 176, 208, 240),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildTreatmentCard(Map<String, dynamic> treatment, bool isDark, String currentLanguage) {
    final bool isWarning = treatment['status'] == 'warning';
    
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
                        treatment['patientName'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        treatment['treatmentName'],
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
                    treatment['medication'],
                    Icons.medication,
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    AppLocalizations.get('next_appointment', currentLanguage),
                    treatment['nextAppointment'],
                    Icons.calendar_today,
                    isDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            if (treatment['note'].isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${AppLocalizations.get('note', currentLanguage)}: ${treatment['note']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
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
