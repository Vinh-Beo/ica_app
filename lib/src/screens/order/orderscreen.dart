import 'package:flutter/material.dart';
import 'package:ica_app/src/cores/components/cards/order_card.dart';
import 'package:ica_app/src/cores/themes/app_colors.dart';
import 'package:ica_app/src/models/order_model.dart';
import 'package:intl/intl.dart';



class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isWeekly = true;
  DateTime selectedDate = DateTime.now();
  late List<DateTime> weekDays;

  @override
  void initState() {
    super.initState();
    weekDays = _getWeekDays(selectedDate);
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = DateFormat('MMM').format(now).toUpperCase();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // NOW button
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 16,
                  //     vertical: 8,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.grey.shade300),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Column(
                  //     children: const [
                  //       Icon(Icons.access_time, size: 24),
                  //       SizedBox(height: 4),
                  //       Text(
                  //         'NOW',
                  //         style: TextStyle(
                  //           fontSize: 12,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  
                  
                  
                  // Profile avatar
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFE8B4F5),
                        child: Text(
                          'K',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.catching_pokemon,
                            size: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Week days
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weekDays.map((date) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedDate = date),
                    child: _buildDayColumn(
                      _getDayName(date.weekday),
                      date.day.toString(),
                      _isSameDay(date, selectedDate),
                      _hasEvents(date),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('EEE d MMM yyyy').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Month label
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Container(
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 12,
            //         vertical: 6,
            //       ),
            //       decoration: BoxDecoration(
            //         color: Colors.grey.shade200,
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: Text(
            //         monthName,
            //         style: const TextStyle(
            //           fontSize: 12,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: // Toggle buttons
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => isWeekly = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isWeekly ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isWeekly
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            'Not delivered',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isWeekly ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => isWeekly = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: !isWeekly ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: !isWeekly
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: !isWeekly ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ),
            ),
            const SizedBox(height: 24),
            // Events list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: _buildOrdersList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasEvents(DateTime date) {
    // Simulate some events on specific days
    return date.weekday == DateTime.monday ||
           date.weekday == DateTime.wednesday ||
           date.weekday == DateTime.thursday ||
           date.weekday == DateTime.friday ||
           date.weekday == DateTime.sunday;
  }

  List<Widget> _buildOrdersList() {
    return [
      orderCard(
        cusId: 1,
        cusName: '179 Nguyễn Văn Trỗi',
        time: '${DateTime.now().hour} am',
        content: '30kg cá cờ',
        delivery_time: 'Giao lúc 6h',
        icon: '👕',
        color: const Color(0xFFFFB84D),
        status: OrderStatus.delivered,
      ),
      const SizedBox(height: 16),
      orderCard(
        time: '9 am',
        cusId: 1,
        cusName: 'Landmark',
        delivery_time: 'Giao lúc 9h',
        content: '50kg cá tầm',
        icon: '🚸',
        color: const Color(0xFFFFB84D),
        status: OrderStatus.delivered,
      ),
      const SizedBox(height: 16),
      orderCard(
        time: '9 pm',
        cusId: 3,
        cusName: 'Hoa phượng đỏ',
        delivery_time: 'Giao lúc 9h',
        content: '5kg diêu hồng\n5kg cá lóc',
        icon: '☕',
        color: const Color(0xFFFF69B4),
        status: OrderStatus.delivered,
        isSecondary: true,
      ),
      const SizedBox(height: 16),
      orderCard(
        time: '9 am',
        cusId: 4,
        cusName: 'Aroma',
        delivery_time: 'Giao lúc 9h',
        content: '72 con chẽm\n50kg dh phi lê\n50 con cá mú',
        icon: '🚸',
        color: const Color(0xFFFFB84D),
        status: OrderStatus.delivered,
      ),
      const SizedBox(height: 16),
      orderCard(
        time: '9 am',
        cusId: 5,
        cusName: 'Lan rừng',
        delivery_time: '',
        content: '5 con chẽm\n4 con mú',
        icon: '🚸',
        color: const Color(0xFFFFB84D),
        status: OrderStatus.delivered,
      )
    ];
  }

  Widget _buildDayColumn(String day, String date, bool isSelected, bool hasEvent) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            date,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: hasEvent ? const Color(0xFFFFB84D) : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}