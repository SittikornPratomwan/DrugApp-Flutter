import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class DrugStockPage extends StatefulWidget {
  final int? locationId;
  
  const DrugStockPage({super.key, this.locationId});

  @override
  State<DrugStockPage> createState() => _DrugStockPageState();
}

class _DrugStockPageState extends State<DrugStockPage> {
  List<dynamic> drugs = [];
  List<dynamic> filteredDrugs = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDrugs();
  }

  Future<void> fetchDrugs() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse(ApiConfig.drugsProductEndpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> allDrugs = jsonDecode(response.body);
        
        // Debug: แสดงข้อมูลจาก API
        if (allDrugs.isNotEmpty) {
          print('=== DRUG STOCK DEBUG ===');
          print('Total drugs from API: ${allDrugs.length}');
          print('Sample drug: ${allDrugs.first}');
          print('Available fields: ${allDrugs.first.keys.toList()}');
          print('Widget locationId: ${widget.locationId}');
        }

        // กรองยาตาม locationId ถ้ามี
        List<dynamic> drugsToShow = allDrugs;
        if (widget.locationId != null) {
          drugsToShow = allDrugs.where((drug) {
            if (drug['location_id'] != null) {
              String drugLocationId = drug['location_id'].toString();
              String widgetLocationId = widget.locationId.toString();
              return drugLocationId == widgetLocationId;
            }
            return false;
          }).toList();
          
          print('Filtered drugs by location: ${drugsToShow.length}');
        }

        setState(() {
          drugs = drugsToShow;
          filteredDrugs = drugsToShow;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load drugs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching drugs: $e');
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void filterDrugs(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredDrugs = drugs;
      } else {
        filteredDrugs = drugs.where((drug) {
          final productName = (drug['product_name']?.toString() ?? '').toLowerCase();
          final productId = (drug['product_id']?.toString() ?? '').toLowerCase();
          final brand = (drug['brand']?.toString() ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          
          return productName.contains(searchLower) ||
                 productId.contains(searchLower) ||
                 brand.contains(searchLower);
        }).toList();
      }
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'ไม่ระบุ';
    
    try {
      // ถ้าเป็นรูปแบบ ddmmyyyy
      if (dateStr.length == 8) {
        String day = dateStr.substring(0, 2);
        String month = dateStr.substring(2, 4);
        String year = dateStr.substring(4, 8);
        return '$day/$month/$year';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  bool isExpiringSoon(String? expDate) {
    if (expDate == null || expDate.isEmpty) return false;
    
    try {
      if (expDate.length == 8) {
        int day = int.parse(expDate.substring(0, 2));
        int month = int.parse(expDate.substring(2, 4));
        int year = int.parse(expDate.substring(4, 8));
        
        DateTime expDateTime = DateTime(year, month, day);
        DateTime now = DateTime.now();
        DateTime twoMonthsFromNow = DateTime(now.year, now.month + 2, now.day);
        
        return expDateTime.isBefore(twoMonthsFromNow) && expDateTime.isAfter(now);
      }
    } catch (e) {
      return false;
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'คลังยา',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDrugs,
            tooltip: 'รีเฟรชข้อมูล',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: filterDrugs,
              decoration: InputDecoration(
                hintText: 'ค้นหายา (ชื่อ, รหัส, แบรนด์)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          filterDrugs('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),

          // Results Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'พบยา ${filteredDrugs.length} รายการ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (widget.locationId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      'สาขา: ${getLocationName(widget.locationId)}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Drug List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredDrugs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medication_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isNotEmpty
                                  ? 'ไม่พบยาที่ค้นหา'
                                  : 'ไม่มีข้อมูลยา',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  searchController.clear();
                                  filterDrugs('');
                                },
                                child: const Text('แสดงยาทั้งหมด'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchDrugs,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredDrugs.length,
                          itemBuilder: (context, index) {
                            final drug = filteredDrugs[index];
                            return _buildDrugCard(drug, isDark);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String getLocationName(int? locationId) {
    switch (locationId) {
      case 1:
        return 'ลำลูกกา';
      case 2:
        return 'บ้านบึง';
      case 3:
        return 'สำนักงานใหญ่';
      default:
        return 'ไม่ระบุ';
    }
  }

  Widget _buildDrugCard(Map<String, dynamic> drug, bool isDark) {
    final isExpiring = isExpiringSoon(drug['exp']?.toString());
    final stockLevel = drug['item']?.toString() ?? '0';
    final isLowStock = int.tryParse(stockLevel) != null && int.parse(stockLevel) < 10;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isExpiring || isLowStock
              ? Border.all(color: Colors.orange, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Product Name and Alerts
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drug['name']?.toString() ?? 'ไม่ระบุชื่อ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (drug['brand'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'แบรนด์: ${drug['brand']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (isExpiring)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ใกล้หมดอายุ',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isLowStock) ...[
                        if (isExpiring) const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'สต็อกต่ำ',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Product Details Grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('รหัสสินค้า', drug['product_id']?.toString() ?? 'ไม่ระบุ', Icons.qr_code),
                    const Divider(height: 16),
                    _buildDetailRow('จำนวนคงเหลือ', '$stockLevel หน่วย', Icons.inventory_2, 
                        textColor: isLowStock ? Colors.red : null),
                    const Divider(height: 16),
                    _buildDetailRow('วันหมดอายุ', formatDate(drug['exp']?.toString()), Icons.calendar_today,
                        textColor: isExpiring ? Colors.orange : null),
                    if (drug['lot_number'] != null) ...[
                      const Divider(height: 16),
                      _buildDetailRow('หมายเลข Lot', drug['lot_number'].toString(), Icons.batch_prediction),
                    ],
                    if (drug['unit_price'] != null) ...[
                      const Divider(height: 16),
                      _buildDetailRow('ราคาต่อหน่วย', '${drug['unit_price']} บาท', Icons.attach_money),
                    ],
                    if (drug['location_id'] != null) ...[
                      const Divider(height: 16),
                      _buildDetailRow('สาขา', getLocationName(int.tryParse(drug['location_id'].toString())), Icons.location_on),
                    ],
                  ],
                ),
              ),

              // Additional Information
              if (drug['description'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 6),
                          Text(
                            'รายละเอียด',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        drug['description'].toString(),
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? textColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white70 : Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor ?? (isDark ? Colors.white : Colors.black87),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
