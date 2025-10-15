import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ica_app/l10n/l10n.dart';
import 'package:ica_app/src/cores/animations/page_transition.dart';
import 'package:ica_app/src/cores/themes/app_theme.dart';
import 'package:ica_app/src/onboarding/onboarding_screen.dart';
import 'package:ica_app/src/recipes/domain/recipe.dart';
import 'package:ica_app/src/recipes/presentation/widgets/home_screens/animated_category_list.dart';
import 'package:ica_app/src/screens/purchase/purchase_screen.dart';
import 'package:ica_app/src/screens/splash/splash_screen.dart';
import 'src/recipes/presentation/screens/recipe_details_screen.dart';

void main() {
  runApp(DevicePreview(
          enabled: !kReleaseMode, // Disable in release mode
          builder: (context) => const MyApp(),
        ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
   Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class DribbleChallenge extends StatelessWidget {
  const DribbleChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      home: const OnBoardingScreen(),
      onGenerateRoute: (settings) {
        return switch (settings.name) {
          'home' => NoAnimationTransition(
              builder: (context) => const HomeScreen(),
            ),
          'recipe_details' => NoAnimationTransition(
              builder: (context) => RecipeDetailsScreen(recipe: settings.arguments as Recipe),
            ),
          _ => NoAnimationTransition(builder: (context) => const GeminiApp())
        };
      },
      theme: mainTheme,
      darkTheme: mainTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
    );
    //return const LoginScreen();
  }
} 
class GeminiApp extends StatelessWidget {
  const GeminiApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Gemini UI',
      locale: DevicePreview.locale(context), // Get locale from Device Preview
      builder: DevicePreview.appBuilder, // R
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1F21),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1F21),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2E2E31),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}



// class CartItemWidget extends StatelessWidget {
//   final CartItem item;
//   final Function(int) onQuantityChanged;

//   const CartItemWidget({
//     super.key,
//     required this.item,
//     required this.onQuantityChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Product Image
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10.0),
//             child: Image.network(
//               item.imageUrl,
//               width: 80,
//               height: 80,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) => Container(
//                 width: 80,
//                 height: 80,
//                 color: Colors.grey[200],
//                 child: const Icon(Icons.image_not_supported, color: Colors.grey),
//               ),
//             ),
//           ),
//           const SizedBox(width: 15),

//           // Product Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.name,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   item.description,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: Colors.grey[600],
//                       ),
//                 ),
//                 const SizedBox(height: 5),
//                 Row(
//                   children: [
//                     Text(
//                       '${item.currentPrice.toStringAsFixed(2)} €',
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                     ),
//                     // if (item.currentWeight != null) ...[
//                     //   const SizedBox(width: 8),
//                     //   Text(
//                     //     '${item.currentWeight!.toStringAsFixed(2)} €',
//                     //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     //           color: Colors.grey,
//                     //           decoration: TextDecoration.lineThrough,
//                     //         ),
//                     //   ),
//                     // ],
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 15),

//           // Quantity Controls
//           Container(
//             decoration: BoxDecoration(
//               color: AppColors.onBoardingButtonColor, // Purple background
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.remove, color: Colors.white, size: 20),
//                   onPressed: () => onQuantityChanged(-1),
//                   splashRadius: 20,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Text(
//                     '${item.quantity}',
//                     style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.add, color: Colors.white, size: 20),
//                   onPressed: () => onQuantityChanged(1),
//                   splashRadius: 20,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // final avatarPlayDuration = 500.ms;
    // final avatarWaitingDuration = 400.ms;
    // final nameDelayDuration = avatarWaitingDuration + avatarWaitingDuration + 200.ms;
    // final namePlayDuration = 800.ms;
    // final categoryListPlayDuration = 750.ms;
    // final categoryListDelayDuration = nameDelayDuration + namePlayDuration - 400.ms;
    // final selectedCategoryPlayDuration = 400.ms;
    // final selectedCategoryDelayDuration = categoryListDelayDuration + categoryListPlayDuration;


    // final List<CartItem> _cartItems = [
    //   CartItem(
    //     id: '1',
    //     imageUrl: 'https://i.imgur.com/G4P4Q4z.png', // Placeholder for Hibiki Whisky
    //     name: 'Hibiki Whisky',
    //     description: '43% 0.7L',
    //     currentPrice: 99.90,
    //     currentWeight: 119.90,
    //     quantity: 2,
    //   ),
    //   CartItem(
    //     id: '2',
    //     imageUrl: 'https://i.imgur.com/8Q0N9Xk.png', // Placeholder for Tom Ford Portofino
    //     name: 'Tom Ford Portofino',
    //     description: '100 ml',
    //     currentPrice: 379.90,
    //     currentWeight: 119.90,
    //     quantity: 1,
    //   ),
    //   CartItem(
    //     id: '3',
    //     imageUrl: 'https://i.imgur.com/A6D3F9c.png', // Placeholder for Caramel Brulee Latte
    //     name: 'Caramel Brulee Latte',
    //     description: '400 ml',
    //     currentPrice: 4.20,
    //     currentWeight: 119.90,
    //     quantity: 1,
    //     category: 'STARBUCKS',
    //   ),
    // ];
    String? currentCategory;
    final List<Widget> cartWidgets = [];

    // void _updateQuantity(String itemId, int change) {
    //   setState(() {
    //     final itemIndex = _cartItems.indexWhere((item) => item.id == itemId);
    //     if (itemIndex != -1) {
    //       _cartItems[itemIndex].quantity += change;
    //       if (_cartItems[itemIndex].quantity < 0) {
    //         _cartItems[itemIndex].quantity = 0; // Prevent negative quantity
    //       }
    //     }
    //   });
    // }

    // for (var item in _cartItems) {
    //   if (item.category != null && item.category != currentCategory) {
    //     cartWidgets.add(
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    //         child: Row(
    //           children: [
    //             Text(
    //               item.category!.toUpperCase(),
    //               style: Theme.of(context).textTheme.titleLarge?.copyWith(
    //                 color: Colors.black,
    //                 letterSpacing: 1.5,
    //               ),
    //             ),
    //             const SizedBox(width: 8),
    //             const Icon(Icons.info_outline, size: 18, color: Colors.grey),
    //           ],
    //         ),
    //       ),
    //     );
    //     currentCategory = item.category;
    //   }
    //   cartWidgets.add(
    //     CartItemWidget(
    //       item: item,
    //       onQuantityChanged: (change) => _updateQuantity(item.id, change),
    //     ),
    //   );
    //   cartWidgets.add(const SizedBox(height: 10)); // Spacer between items
    // }

  //   final List<CartItem> cartItems = [
  //   CartItem(
  //     name: 'Almonds',
  //     price: 150.000,
  //     weight: 10.00,
  //     quantity: 2,
  //     imageUrl: 'assets/almonds.png',
  //   ),
  //   CartItem(
  //     name: 'Mix dry\nfruits',
  //     price: 90.000,
  //     weight: 10.00,
  //     quantity: 2,
  //     imageUrl: 'assets/mix_dry_fruits.png',
  //   ),
  //   CartItem(
  //     name: 'Coffee',
  //     price: 100.000,
  //     weight: 10.00,
  //     quantity: 2,
  //     imageUrl: 'assets/coffee.png',
  //   ),
  // ];

  //   void _incrementQuantity(int index) {
  //   setState(() {
  //     cartItems[index].quantity++;
  //   });
  // }

  // void _decrementQuantity(int index) {
  //   setState(() {
  //     if (cartItems[index].quantity > 1) {
  //       cartItems[index].quantity--;
  //     }
  //   });
  // }

  // void _removeItem(int index) {
  //   setState(() {
  //     cartItems.removeAt(index);
  //   });
  // }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gemini',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: const Row(
                children: [
                  Text(
                    '2.5 Flash',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(  
            child: Container(),
            // Thêm cái này
            // child: ListView.builder(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   itemCount: cartItems.length,
            //   itemBuilder: (context, index) {
            //     return CartItemCard(
            //       item: cartItems[index],
            //       onIncrement: () => _incrementQuantity(index),
            //       onDecrement: () => _decrementQuantity(index),
            //       onRemove: () => _removeItem(index),
            //     );
            //   },
            // ),
          ),
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 80,
          //   child: SizedBox(
          //     height: 80,
          //     child: AnimatedCategoryList(
          //         categoryListPlayDuration: categoryListPlayDuration,
          //         categoryListDelayDuration: categoryListDelayDuration,
          //       ),
          //   ),
          // ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        color: const Color(0xFF1E1F21),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E31),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:  const Row(
                children: [
                   Icon(Icons.add_rounded, color: Colors.white, size: 24),
                   SizedBox(width: 8),
                   Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Ask Gemini',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.send, color: Colors.white, size: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}