import 'package:flutter/material.dart';

class AddDrugPage extends StatefulWidget {
  const AddDrugPage({super.key});

  @override
  State<AddDrugPage> createState() => _AddDrugPageState();
}

class _AddDrugPageState extends State<AddDrugPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  String? selectedCategory;

  final List<String> categories = [
    'ยาแก้ปวด',
    'ยาแก้ไข้',
    'ยาแก้อักเสบ',
    'วิตามิน',
    'อื่นๆ',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มข้อมูลยา', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 176, 208, 240),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อยา',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกชื่อยา' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                )).toList(),
                onChanged: (val) => setState(() => selectedCategory = val),
                decoration: const InputDecoration(
                  labelText: 'หมวดหมู่',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) => value == null || value.isEmpty ? 'กรุณาเลือกหมวดหมู่' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: typeController,
                decoration: const InputDecoration(
                  labelText: 'ประเภท/รูปแบบ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'จำนวนคงเหลือ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกจำนวนคงเหลือ' : null,
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('บันทึกข้อมูล', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 176, 208, 240),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: ส่งข้อมูลไปยัง backend หรือบันทึกใน local
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('บันทึกข้อมูลยาเรียบร้อย!')),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
