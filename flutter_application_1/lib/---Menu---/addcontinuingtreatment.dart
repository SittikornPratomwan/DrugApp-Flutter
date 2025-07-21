import 'package:flutter/material.dart';
import '../---Translate---/vocabulary.dart';
import '../---Translate---/locale_manager.dart';

class AddContinuingTreatmentPage extends StatefulWidget {
  const AddContinuingTreatmentPage({super.key});

  @override
  State<AddContinuingTreatmentPage> createState() => _AddContinuingTreatmentPageState();
}

class _AddContinuingTreatmentPageState extends State<AddContinuingTreatmentPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final currentLanguage = localeManager.currentLocale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get('add_continuing_treatment', currentLanguage)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.get('treatment_name', currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: AppLocalizations.get('enter_treatment_name', currentLanguage),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.get('note', currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: AppLocalizations.get('enter_note', currentLanguage),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.get('reminder_date', currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(selectedDate == null
                      ? AppLocalizations.get('select_date', currentLanguage)
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(AppLocalizations.get('choose', currentLanguage)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_alert),
                label: Text(AppLocalizations.get('save_treatment', currentLanguage)),
                onPressed: () {
                  // TODO: Save treatment and show notification
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.get('treatment_saved', currentLanguage)),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
