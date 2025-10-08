// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ica_app/src/recipes/presentation/widgets/home_screens/food_category_widget.dart';

class AnimatedCategoryList extends StatelessWidget {
  final Duration categoryListPlayDuration;
  final Duration categoryListDelayDuration;
  const AnimatedCategoryList({
    Key? key,
    required this.categoryListPlayDuration,
    required this.categoryListDelayDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 50, minHeight: 40),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 15),
        children: List.generate(_categories.length, (index) => _categories[index])
            .animate(interval: 10.ms, delay: categoryListDelayDuration)
            .slideX(
                duration: categoryListPlayDuration, begin: 3, end: 0, curve: Curves.easeInOutSine),
      ),
    );
  }
}

const _categories = [
  FoodCategoryWidget(icon: "🐟", name: "Cá chẽm"),
  FoodCategoryWidget(icon: "🐟", name: "Cá bớp"),
  FoodCategoryWidget(icon: "🐟", name: "Cá dứa"),
  FoodCategoryWidget(icon: "🐟", name: "Cá đuối"),
  FoodCategoryWidget(icon: "🦐", name: "Tôm thẻ"),
  FoodCategoryWidget(icon: "🦐", name: "Tôm sú"),
  FoodCategoryWidget(icon: "🐟", name: "Cá lóc"),
  FoodCategoryWidget(icon: "🐟", name: "Cá diêu hồng"),
  FoodCategoryWidget(icon: "🐟", name: "Cá thu"),
  FoodCategoryWidget(icon: "🐟", name: "Cá mú"),
  FoodCategoryWidget(icon: "🍿", name: "Chả cá thác lác"),
  FoodCategoryWidget(icon: "🍿", name: "Chả cá thu"),
  FoodCategoryWidget(icon: "🦑", name: "Mực"),
  FoodCategoryWidget(icon: "🦑", name: "Mực sữa"),
  FoodCategoryWidget(icon: "🦑", name: "Bạch tuộc"),
  FoodCategoryWidget(icon: "🦪", name: "Hào"),
  FoodCategoryWidget(icon: "🦀", name: "Cua"),
  FoodCategoryWidget(icon: "🐸", name: "Ếch"),
];