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
  String selectedFilter = 'ทั้งหมด'; // เพิ่มตัวแปรสำหรับกรอง
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
      applyFilters();
    });
  }

  void applyFilters() {
    List<dynamic> result = drugs;

    // กรองตามคำค้นหา
    if (searchQuery.isNotEmpty) {
      result = result.where((drug) {
        final productName = (drug['name']?.toString() ?? '').toLowerCase();
        final productId = (drug['product_id']?.toString() ?? '').toLowerCase();
        final brand = (drug['brand']?.toString() ?? '').toLowerCase();
        final searchLower = searchQuery.toLowerCase();
        
        return productName.contains(searchLower) ||
               productId.contains(searchLower) ||
               brand.contains(searchLower);
      }).toList();
    }

    // กรองตามสถานะ
    if (selectedFilter != 'ทั้งหมด') {
      result = result.where((drug) {
        final isExpiring = isExpiringSoon(drug['exp']?.toString());
        final isExpiredDrug = isExpired(drug['exp']?.toString());
        final stockLevel = drug['item']?.toString() ?? '0';
        final stockCount = int.tryParse(stockLevel) ?? 0;
        final isLowStock = stockCount < 10 && stockCount > 0;
        final isOutOfStock = stockCount == 0; // เพิ่มการตรวจสอบสต็อกหมด

        switch (selectedFilter) {
          case 'ใกล้หมดอายุ':
            return isExpiring && !isExpiredDrug;
          case 'หมดอายุ':
            return isExpiredDrug;
          case 'สต็อกต่ำ':
            return isLowStock;
          case 'สต็อกหมด': // เพิ่มกรองสต็อกหมด
            return isOutOfStock;
          default:
            return true;
        }
      }).toList();
    }

    setState(() {
      filteredDrugs = result;
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

  // เพิ่มฟังก์ชันตรวจสอบว่ายาหมดอายุแล้วหรือไม่
  bool isExpired(String? expDate) {
    if (expDate == null || expDate.isEmpty) return false;
    try {
      if (expDate.length == 8) {
        int day = int.parse(expDate.substring(0, 2));
        int month = int.parse(expDate.substring(2, 4));
        int year = int.parse(expDate.substring(4, 8));
        DateTime expDateTime = DateTime(year, month, day);
        DateTime now = DateTime.now();
        return expDateTime.isBefore(now);
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
          // ปุ่มกรอง (Dropdown)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: selectedFilter != 'ทั้งหมด' ? Colors.orange : null,
            ),
            tooltip: 'กรองข้อมูล',
            onSelected: (String value) {
              setState(() {
                selectedFilter = value;
              });
              applyFilters();
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'ทั้งหมด',
                child: Row(
                  children: [
                    Icon(
                      Icons.all_inclusive,
                      size: 20,
                      color: selectedFilter == 'ทั้งหมด' ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ทั้งหมด',
                      style: TextStyle(
                        fontWeight: selectedFilter == 'ทั้งหมด' ? FontWeight.bold : FontWeight.normal,
                        color: selectedFilter == 'ทั้งหมด' ? Colors.blue : null,
                      ),
                    ),
                    if (selectedFilter == 'ทั้งหมด') ...[
                      const Spacer(),
                      const Icon(Icons.check, color: Colors.blue, size: 18),
                    ],
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'ใกล้หมดอายุ',
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 20,
                      color: selectedFilter == 'ใกล้หมดอายุ' ? Colors.orange : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ใกล้หมดอายุ',
                      style: TextStyle(
                        fontWeight: selectedFilter == 'ใกล้หมดอายุ' ? FontWeight.bold : FontWeight.normal,
                        color: selectedFilter == 'ใกล้หมดอายุ' ? Colors.orange : null,
                      ),
                    ),
                    if (selectedFilter == 'ใกล้หมดอายุ') ...[
                      const Spacer(),
                      const Icon(Icons.check, color: Colors.orange, size: 18),
                    ],
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'หมดอายุ',
                child: Row(
                  children: [
                    Icon(
                      Icons.dangerous,
                      size: 20,
                      color: selectedFilter == 'หมดอายุ' ? Colors.brown : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'หมดอายุ',
                      style: TextStyle(
                        fontWeight: selectedFilter == 'หมดอายุ' ? FontWeight.bold : FontWeight.normal,
                        color: selectedFilter == 'หมดอายุ' ? Colors.brown : null,
                      ),
                    ),
                    if (selectedFilter == 'หมดอายุ') ...[
                      const Spacer(),
                      const Icon(Icons.check, color: Colors.brown, size: 18),
                    ],
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'สต็อกต่ำ',
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 20,
                      color: selectedFilter == 'สต็อกต่ำ' ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'สต็อกต่ำ',
                      style: TextStyle(
                        fontWeight: selectedFilter == 'สต็อกต่ำ' ? FontWeight.bold : FontWeight.normal,
                        color: selectedFilter == 'สต็อกต่ำ' ? Colors.red : null,
                      ),
                    ),
                    if (selectedFilter == 'สต็อกต่ำ') ...[
                      const Spacer(),
                      const Icon(Icons.check, color: Colors.red, size: 18),
                    ],
                  ],
                ),
              ),
              // เพิ่มตัวเลือกสต็อกหมด
              PopupMenuItem<String>(
                value: 'สต็อกหมด',
                child: Row(
                  children: [
                    Icon(
                      Icons.remove_circle_outline,
                      size: 20,
                      color: selectedFilter == 'สต็อกหมด' ? Colors.red.shade800 : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'สต็อกหมด',
                      style: TextStyle(
                        fontWeight: selectedFilter == 'สต็อกหมด' ? FontWeight.bold : FontWeight.normal,
                        color: selectedFilter == 'สต็อกหมด' ? Colors.red.shade800 : null,
                      ),
                    ),
                    if (selectedFilter == 'สต็อกหมด') ...[
                      const Spacer(),
                      Icon(Icons.check, color: Colors.red.shade800, size: 18),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // ปุ่มรีเฟรช
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

          // Status Indicator (แสดงสถานะการกรองปัจจุบัน)
          if (selectedFilter != 'ทั้งหมด')
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getFilterColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getFilterColor()),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFilterIcon(),
                    size: 16,
                    color: _getFilterColor(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'กรองแสดง: $selectedFilter',
                    style: TextStyle(
                      color: _getFilterColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = 'ทั้งหมด';
                      });
                      applyFilters();
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: _getFilterColor(),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

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
                              searchQuery.isNotEmpty || selectedFilter != 'ทั้งหมด'
                                  ? 'ไม่พบยาที่ค้นหา'
                                  : 'ไม่มีข้อมูลยา',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (searchQuery.isNotEmpty || selectedFilter != 'ทั้งหมด') ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {
                                    searchQuery = '';
                                    selectedFilter = 'ทั้งหมด';
                                  });
                                  applyFilters();
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
    final isExpiredDrug = isExpired(drug['exp']?.toString());
    final stockLevel = drug['item']?.toString() ?? '0';
    final stockCount = int.tryParse(stockLevel) ?? 0;
    final isLowStock = stockCount < 10 && stockCount > 0;
    final isOutOfStock = stockCount == 0; // เพิ่มการตรวจสอบสต็อกหมด

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isExpiredDrug
              ? Border.all(color: Colors.red, width: 2) // หมดอายุแล้ว = แดง
              : isOutOfStock
                  ? Border.all(color: Colors.grey, width: 2) // หมด = เทา
                  : isExpiring
                      ? Border.all(color: Colors.yellow, width: 2) // ใกล้หมดอายุ = เหลือง
                      : isLowStock
                          ? Border.all(color: Colors.orange, width: 2) // สต็อกต่ำ = ส้ม
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
                      if (isExpiredDrug)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'หมดอายุ',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      // เพิ่มป้ายสต็อกหมด
                      if (isOutOfStock)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'หมด',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (!isExpiredDrug && !isOutOfStock && isExpiring)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ใกล้หมดอายุ',
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (!isOutOfStock && isLowStock) ...[
                        if (isExpiring || isExpiredDrug) const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'สต็อกต่ำ',
                            style: TextStyle(
                              color: Colors.orange,
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
                        textColor: isOutOfStock 
                            ? Colors.red.shade800 
                            : isLowStock 
                                ? Colors.red 
                                : null),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'วันหมดอายุ',
                      formatDate(drug['exp']?.toString()),
                      Icons.calendar_today,
                      textColor: isExpiredDrug
                          ? Colors.brown
                          : isExpiring
                              ? Colors.orange
                              : null,
                    ),
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

// Helper methods สำหรับ filter indicator

extension _DrugStockPageStateHelpers on _DrugStockPageState {
  Color _getFilterColor() {
    switch (selectedFilter) {
      case 'ใกล้หมดอายุ':
        return Colors.yellow;
      case 'หมดอายุ':
        return Colors.red;
      case 'สต็อกต่ำ':
        return Colors.orange;
      case 'สต็อกหมด':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getFilterIcon() {
    switch (selectedFilter) {
      case 'ใกล้หมดอายุ':
        return Icons.warning;
      case 'หมดอายุ':
        return Icons.dangerous;
      case 'สต็อกต่ำ':
        return Icons.inventory_2;
      case 'สต็อกหมด':
        return Icons.remove_circle_outline; // เพิ่มไอคอนสำหรับสต็อกหมด
      default:
        return Icons.all_inclusive;
    }
  }
}
