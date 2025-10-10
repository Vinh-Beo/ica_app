import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ica_app/src/cores/components/app_bar/p_app_bar.dart';
import 'package:ica_app/src/cores/components/cards/debt_card.dart';
import 'package:intl/intl.dart';



class DebtScreen extends StatefulWidget {
  const DebtScreen({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  bool isWeekly = true;
  DateTime selectedDate = DateTime.now();
  late List<DateTime> weekDays;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PCustomizeAppBar(
        isShowLeadingButton: false,
        title: "Tên khách hàng",
        rightWidget: PCustomizeAppBar.buildRightWidget(
        SvgPicture.asset(
          'assets/images/ic_plus_add.svg',
          height: 24,
          width: 24,
          ),
          onTap: () async {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: _buildDebtsList(),
              ),
      ),
    );
  }

  List<Widget> _buildDebtsList() {
    return [
      const SizedBox(height: 16),
      debtCard(
        cusId: 1,
        cusName: '179 Nguyễn Văn Trỗi',
        time: '${DateTime.now().hour} am',
        content: '30kg cá cờ',
        delivery_time: 'Giao lúc 6h',
        icon: '👕',
        color: const Color(0xFFFFB84D),
        debt_total: '-400.000đ',
      ),
      const SizedBox(height: 16),
      debtCard(
        time: '9 am',
        cusId: 1,
        cusName: 'Landmark',
        delivery_time: 'Giao lúc 9h',
        content: '50kg cá tầm',
        icon: '🚸',
        color: const Color(0xFFFFB84D),
        debt_total: '-300.000đ',
      ),
      const SizedBox(height: 16),
      debtCard(
        time: '9 pm',
        cusId: 3,
        cusName: 'Hoa phượng đỏ',
        delivery_time: 'Giao lúc 9h',
        content: '5kg diêu hồng\n5kg cá lóc',
        icon: '☕',
        color: const Color(0xFFFF69B4),
        debt_total: '-1.400.000đ',
        isSecondary: true,
      ),
      const SizedBox(height: 16),
      debtCard(
        time: '9 am',
        cusId: 4,
        cusName: 'Aroma',
        delivery_time: 'Giao lúc 9h',
        content: '72 con chẽm\n50kg dh phi lê\n50 con cá mú',
        icon: '🚸',
        color: const Color(0xFFFFB84D),
        debt_total: '-500.000đ',
      ),
      const SizedBox(height: 16),
      debtCard(
        time: '9 am',
        cusId: 5,
        cusName: 'Lan rừng',
        delivery_time: '',
        content: '5 con chẽm\n4 con mú',
        icon: '🚸',
        color: const Color(0xFFFFB84D),
        debt_total: '-100.000đ',
      )
    ];
  }
}