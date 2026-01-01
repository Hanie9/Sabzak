import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'گزارش‌ها'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton(0, 'گزارش فروش'),
                _buildTabButton(1, 'گزارش گیاهان'),
                _buildTabButton(2, 'گزارش کاربران'),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _SalesReportTab(apiService: _apiService),
                _PlantSalesReportTab(apiService: _apiService),
                _UserActivityReportTab(apiService: _apiService),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Constant.primaryColor : Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontFamily: 'Yekan Bakh',
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _SalesReportTab extends StatefulWidget {
  final ApiService apiService;
  const _SalesReportTab({required this.apiService});

  @override
  State<_SalesReportTab> createState() => _SalesReportTabState();
}

class _SalesReportTabState extends State<_SalesReportTab> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final reports = await widget.apiService.getSalesReport();
      setState(() {
        _reports = reports;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reports.isEmpty) {
      return const Center(
        child: Text(
          'گزارشی یافت نشد',
          style: TextStyle(fontFamily: 'Yekan Bakh', fontSize: 18),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              title: Text('سفارش: ${report['order_number'] ?? ''}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مشتری: ${report['username'] ?? ''}'),
                  Text('مبلغ کل: ${report['total_amount'] ?? 0} تومان'),
                  Text('تعداد آیتم: ${report['items_count'] ?? 0}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlantSalesReportTab extends StatefulWidget {
  final ApiService apiService;
  const _PlantSalesReportTab({required this.apiService});

  @override
  State<_PlantSalesReportTab> createState() => _PlantSalesReportTabState();
}

class _PlantSalesReportTabState extends State<_PlantSalesReportTab> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final reports = await widget.apiService.getPlantSalesReport();
      setState(() {
        _reports = reports;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reports.isEmpty) {
      return const Center(
        child: Text(
          'گزارشی یافت نشد',
          style: TextStyle(fontFamily: 'Yekan Bakh', fontSize: 18),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              title: Text('${report['plantname'] ?? ''}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('دسته‌بندی: ${report['category'] ?? ''}'),
                  Text('قیمت: ${report['price'] ?? 0} تومان'),
                  Text('تعداد فروش: ${report['times_sold'] ?? 0}'),
                  Text('تعداد کل: ${report['total_quantity_sold'] ?? 0}'),
                  Text('درآمد کل: ${report['total_revenue'] ?? 0} تومان'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserActivityReportTab extends StatefulWidget {
  final ApiService apiService;
  const _UserActivityReportTab({required this.apiService});

  @override
  State<_UserActivityReportTab> createState() => _UserActivityReportTabState();
}

class _UserActivityReportTabState extends State<_UserActivityReportTab> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final reports = await widget.apiService.getUserActivityReport();
      setState(() {
        _reports = reports;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reports.isEmpty) {
      return const Center(
        child: Text(
          'گزارشی یافت نشد',
          style: TextStyle(fontFamily: 'Yekan Bakh', fontSize: 18),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              title: Text('${report['username'] ?? ''}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ایمیل: ${report['email'] ?? ''}'),
                  Text('نوع: ${report['is_admin'] == true ? 'ادمین' : 'کاربر'}'),
                  Text('گیاهان در سبد: ${report['plants_in_cart'] ?? 0}'),
                  Text('گیاهان امتیاز داده شده: ${report['plants_rated'] ?? 0}'),
                  Text('تعداد سفارشات: ${report['orders_count'] ?? 0}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

