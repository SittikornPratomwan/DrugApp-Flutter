import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../---Translate---/vocabulary.dart';
import '../../---Translate---/locale_manager.dart';
import '../../config/api_config.dart';

class AddContinuingTreatmentPage extends StatefulWidget {
  const AddContinuingTreatmentPage({super.key});

  @override
  State<AddContinuingTreatmentPage> createState() => _AddContinuingTreatmentPageState();
}

class _AddContinuingTreatmentPageState extends State<AddContinuingTreatmentPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController fevertypeController = TextEditingController();
  final TextEditingController drugNameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  DateTime? selectedDate;
  DateTime? receiveTime;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    final currentLanguage = localeManager.currentLocale.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get('add_continuing_treatment', currentLanguage)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
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
              Text(AppLocalizations.get('user_id', currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: userIdController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.get('enter_user_id', currentLanguage),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.get('fevertype', currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: fevertypeController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.get('enter_fevertype', currentLanguage),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.get('drug_name', currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: drugNameController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.get('enter_drug_name', currentLanguage),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.get('dosage', currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: dosageController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.get('enter_dosage', currentLanguage),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.get('product_id', currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: productIdController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.get('enter_product_id', currentLanguage),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
              const SizedBox(height: 16),
              Text(AppLocalizations.get('receive_time', currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(receiveTime == null
                        ? AppLocalizations.get('select_date', currentLanguage)
                        : '${receiveTime!.day}/${receiveTime!.month}/${receiveTime!.year}'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          receiveTime = picked;
                        });
                      }
                    },
                    child: Text(AppLocalizations.get('choose', currentLanguage)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.get('status', currentLanguage), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: statusController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.get('enter_status', currentLanguage),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_alert),
                  label: Text(AppLocalizations.get('save_treatment', currentLanguage)),
                  onPressed: isSaving ? null : _saveTreatment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTreatment() async {
    final name = nameController.text.trim();
    final note = noteController.text.trim();
    final userId = userIdController.text.trim();
    final fevertype = fevertypeController.text.trim();
    final drugName = drugNameController.text.trim();
    final dosage = dosageController.text.trim();
    final productId = productIdController.text.trim();
    final status = statusController.text.trim();
    final date = selectedDate;
    final receive = receiveTime;
    final currentLanguage = localeManager.currentLocale.languageCode;

    if (name.isEmpty || userId.isEmpty || fevertype.isEmpty || drugName.isEmpty || dosage.isEmpty || productId.isEmpty || status.isEmpty || date == null || receive == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.get('please_fill_all_fields', currentLanguage)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() { isSaving = true; });
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.addDrugReceiveEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: '{"userId": "$userId", "fevertype": "$fevertype", "drugName": "$drugName", "dosage": "$dosage", "productId": "$productId", "receiveTime": "${receive.toIso8601String()}", "status": "$status", "treatment_name": "$name", "note": "$note", "reminder_date": "${date.toIso8601String()}"}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.get('treatment_saved', currentLanguage)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.get('save_failed', currentLanguage)}: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.get('save_failed', currentLanguage)}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() { isSaving = false; });
    }
  }
}
