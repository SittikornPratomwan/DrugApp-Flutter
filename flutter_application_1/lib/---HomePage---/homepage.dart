import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../---Menu---/drawerpage.dart';
import '../---Translate---/vocabulary.dart';
import '../---Translate---/locale_manager.dart';
import '../config/api_config.dart';


class HomePage extends StatefulWidget {
  final String location;
  final int? locationId;
  const HomePage({super.key, this.location = '', this.locationId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  int allDrugsCount = 0;
  int expiringSoonCount = 0;
  
  // Sample data for demonstration
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'ยาแก้ปวด',
      'icon': Icons.healing,
      'color': Colors.red.shade300,
      'count': 25
    },
    {
      'name': 'ยาแก้ไข้',
      'icon': Icons.thermostat,
      'color': Colors.orange.shade300,
      'count': 18
    },
    {
      'name': 'ยาแก้อักเสบ',
      'icon': Icons.local_hospital,
      'color': Colors.blue.shade300,
      'count': 32
    },
    {
      'name': 'วิตามิน',
      'icon': Icons.health_and_safety,
      'color': Colors.green.shade300,
      'count': 45
    },
  ];

  final List<Map<String, dynamic>> recentDrugs = [
    {
      'name': 'Paracetamol 500mg',
      'category': 'ยาแก้ปวด',
      'stock': 150,
      'expiry': '2025-12-31'
    },
    {
      'name': 'Ibuprofen 400mg',
      'category': 'ยาแก้อักเสบ',
      'stock': 89,
      'expiry': '2025-08-15'
    },
    {
      'name': 'Vitamin C 1000mg',
      'category': 'วิตามิน',
      'stock': 200,
      'expiry': '2026-03-20'
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchAllDrugsCount();
    fetchExpiringSoonCount();
  }

  Future<void> fetchAllDrugsCount() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.drugsProductEndpoint),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> products = jsonDecode(response.body);
        
        // Debug: แสดงข้อมูลตัวอย่างจาก API
        if (products.isNotEmpty) {
          print('=== DEBUG API DATA ===');
          print('Total products from API: ${products.length}');
          print('Sample product from API: ${products.first}');
          print('Available fields in first product: ${products.first.keys.toList()}');
          print('Widget locationId: ${widget.locationId}');
          print('Widget locationId type: ${widget.locationId.runtimeType}');
          
          // แสดงตัวอย่าง location_id จากสินค้า 3 ตัวแรก
          for (int i = 0; i < 3 && i < products.length; i++) {
            var product = products[i];
            print('Product $i location_id: ${product['location_id']} (type: ${product['location_id']?.runtimeType})');
          }
          print('=== END DEBUG ===');
        }
        
        // กรองยาตาม locationId ที่เลือกใน authen
        final filteredProducts = products.where((product) {
          if (widget.locationId != null && product['location_id'] != null) {
            // แปลงทั้งคู่เป็น string เพื่อเปรียบเทียบ
            String productLocationId = product['location_id'].toString();
            String widgetLocationId = widget.locationId.toString();
            
            print('Comparing: product location_id=$productLocationId with widget locationId=$widgetLocationId');
            return productLocationId == widgetLocationId;
          }
          return true; // ถ้าไม่มี locationId ให้แสดงทั้งหมด
        }).toList();
        
        print('Total products: ${products.length}, Filtered products: ${filteredProducts.length}');
        
        setState(() {
          allDrugsCount = filteredProducts.length;
        });
      } else {
        print('Failed to load drugs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all drugs count: $e');
    }
  }

  Future<void> fetchExpiringSoonCount() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.drugsProductEndpoint),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> products = jsonDecode(response.body);
        
        // กรองยาตาม locationId ที่เลือกใน authen
        final filteredProducts = products.where((product) {
          if (widget.locationId != null && product['location_id'] != null) {
            // แปลงทั้งคู่เป็น string เพื่อเปรียบเทียบ
            String productLocationId = product['location_id'].toString();
            String widgetLocationId = widget.locationId.toString();
            return productLocationId == widgetLocationId;
          }
          return true; // ถ้าไม่มี locationId ให้แสดงทั้งหมด
        }).toList();
        
        final DateTime now = DateTime.now();
        final DateTime twoMonthsFromNow = DateTime(now.year, now.month + 2, now.day);
        
        int expiring = 0;
        for (var product in filteredProducts) {
          if (product['exp'] != null) {
            try {
              // แปลง exp จาก ddmmyyyy เป็น DateTime
              String expString = product['exp'].toString();
              if (expString.length == 8) {
                int day = int.parse(expString.substring(0, 2));
                int month = int.parse(expString.substring(2, 4));
                int year = int.parse(expString.substring(4, 8));
                
                DateTime expDate = DateTime(year, month, day);
                
                // ถ้าวันหมดอายุต่ำกว่า 2 เดือนจากวันนี้
                if (expDate.isBefore(twoMonthsFromNow) && expDate.isAfter(now)) {
                  expiring++;
                }
              }
            } catch (e) {
              print('Error parsing exp date: ${product['exp']} - $e');
            }
          }
        }
        
        setState(() {
          expiringSoonCount = expiring;
        });
      } else {
        print('Failed to load drugs for expiring count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching expiring soon count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLanguage = localeManager.currentLocale.languageCode;
    return Scaffold(
      // backgroundColor: Colors.grey.shade50, // ใช้สีจาก Theme
      drawer: const DrawerPage(),
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: Colors.white, // ใช้สีจาก Theme
        centerTitle: true,
        title: Text(
          'Drug${widget.location.isNotEmpty ? ' - ${widget.location}' : ''}',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? (isDark ? Colors.white : Colors.black87),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.get('welcome', currentLanguage),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.get('welcome_message', currentLanguage),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(AppLocalizations.get('all_drugs', currentLanguage), allDrugsCount.toString(), Icons.medication, isDark),
                      const SizedBox(width: 12),
                      _buildStatCard(AppLocalizations.get('expiring_soon', currentLanguage), expiringSoonCount.toString(), Icons.warning_amber, isDark),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.get('search', currentLanguage),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.white70 : Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),

            const SizedBox(height: 24),

            // Categories Section
            Text(
              AppLocalizations.get('drug_categories', currentLanguage),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(category);
              },
            ),

            const SizedBox(height: 24),

            // Recent Drugs Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.get('recent_drugs', currentLanguage),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all drugs
                  },
                  child: Text(AppLocalizations.get('see_all', currentLanguage)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentDrugs.length,
              itemBuilder: (context, index) {
                final drug = recentDrugs[index];
                return _buildDrugCard(drug);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add drug page
        },
        backgroundColor: const Color.fromARGB(255, 176, 208, 240),
        child: const Icon(Icons.medical_services, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLanguage = localeManager.currentLocale.languageCode;
    // Map Thai category names to English if needed
    String categoryName = category['name'];
    if (currentLanguage == 'en') {
      if (categoryName == 'ยาแก้ปวด') categoryName = 'Pain Relievers';
      else if (categoryName == 'ยาแก้ไข้') categoryName = 'Antipyretics';
      else if (categoryName == 'ยาแก้อักเสบ') categoryName = 'Anti-inflammatories';
      else if (categoryName == 'วิตามิน') categoryName = 'Vitamins';
    }
    return GestureDetector(
      onTap: () {
        // Navigate to category page
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category['icon'],
                  size: 32,
                  color: category['color'],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                categoryName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${category['count']} ${AppLocalizations.get('items', currentLanguage)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrugCard(Map<String, dynamic> drug) {
    final bool lowStock = drug['stock'] < 100;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLanguage = localeManager.currentLocale.languageCode;
    // Map Thai category names to English if needed
    String categoryName = drug['category'];
    if (currentLanguage == 'en') {
      if (categoryName == 'ยาแก้ปวด') categoryName = 'Pain Relievers';
      else if (categoryName == 'ยาแก้ไข้') categoryName = 'Antipyretics';
      else if (categoryName == 'ยาแก้อักเสบ') categoryName = 'Anti-inflammatories';
      else if (categoryName == 'วิตามิน') categoryName = 'Vitamins';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: lowStock
                ? (isDark ? Colors.red.shade900 : Colors.red.shade50)
                : (isDark ? Colors.blue.shade900 : Colors.blue.shade50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.medication,
            color: lowStock ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(
          drug['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              categoryName,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  size: 14,
                  color: lowStock ? Colors.red : (isDark ? Colors.white70 : Colors.grey.shade600),
                ),
                const SizedBox(width: 4),
                Text(
                  '${AppLocalizations.get('stock', currentLanguage)}: ${drug['stock']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: lowStock ? Colors.red : (isDark ? Colors.white70 : Colors.grey.shade600),
                    fontWeight: lowStock ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lowStock)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.red.shade900 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.get('low_stock', currentLanguage),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${AppLocalizations.get('expiry', currentLanguage)}: ${drug['expiry']}',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}