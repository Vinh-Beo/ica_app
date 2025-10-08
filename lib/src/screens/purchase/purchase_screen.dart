// import 'package:flutter/material.dart';
// import 'package:ica_app/src/models/Purchase_item_model.dart';

// class PurchaseScreen extends StatelessWidget {
//   const PurchaseScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Purchase List',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         scaffoldBackgroundColor: const Color(0xFFF5F5F5),
//       ),
//       home: const PurchaseListScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class PurchaseListScreen extends StatefulWidget {
//   const PurchaseListScreen({Key? key}) : super(key: key);

//   @override
//   State<PurchaseListScreen> createState() => _PurchaseListScreenState();
// }

// class _PurchaseListScreenState extends State<PurchaseListScreen> {
//   final List<Purchase> Purchases = [
//     Purchase(
//       PurchaseId: '#12345',
//       date: 'Sep 28, 2025',
//       status: PurchaseStatus.delivered,
//       items: [
//         PurchaseItem(name: 'Almonds', quantity: 2, price: 15.00),
//         PurchaseItem(name: 'Mix dry fruits', quantity: 1, price: 9.00),
//       ],
//       total: 39.00,
//     ),
//     Purchase(
//       PurchaseId: '#12344',
//       date: 'Sep 25, 2025',
//       status: PurchaseStatus.inProgress,
//       items: [
//         PurchaseItem(name: 'Coffee', quantity: 3, price: 10.00),
//       ],
//       total: 35.00,
//     ),
//     Purchase(
//       PurchaseId: '#12343',
//       date: 'Sep 20, 2025',
//       status: PurchaseStatus.delivered,
//       items: [
//         PurchaseItem(name: 'Almonds', quantity: 1, price: 15.00),
//         PurchaseItem(name: 'Coffee', quantity: 2, price: 10.00),
//       ],
//       total: 40.00,
//     ),
//     Purchase(
//       PurchaseId: '#12342',
//       date: 'Sep 15, 2025',
//       status: PurchaseStatus.cancelled,
//       items: [
//         PurchaseItem(name: 'Mix dry fruits', quantity: 2, price: 9.00),
//       ],
//       total: 23.00,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {},
//         ),
//         title: const Text(
//           'My Purchases',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: Purchases.length,
//         itemBuilder: (context, index) {
//           return PurchaseCard(Purchase: Purchases[index]);
//         },
//       ),
//     );
//   }
// }



// class PurchaseCard extends StatelessWidget {
//   final Purchase Purchase;

//   const PurchaseCard({
//     Key? key,
//     required this.Purchase,
//   }) : super(key: key);

  

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         bPurchaseRadius: BPurchaseRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Purchase ${Purchase.PurchaseId}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     Purchase.date,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor().withOpacity(0.1),
//                   bPurchaseRadius: BPurchaseRadius.circular(20),
//                 ),
//                 child: Text(
//                   _getStatusText(),
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: _getStatusColor(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Divider(thickness: 1, height: 1),
//           const SizedBox(height: 12),
//           ...Purchase.items.map((item) => Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         '${item.name} x${item.quantity}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                     ),
//                     Text(
//                       '\$${(item.price * item.quantity).toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               )),
//           const SizedBox(height: 12),
//           const Divider(thickness: 1, height: 1),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Total',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               Text(
//                 '\$${Purchase.total.toStringAsFixed(2)}',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               if (Purchase.status == PurchaseStatus.delivered) ...[
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {},
//                     style: OutlinedButton.styleFrom(
//                       side: const BPurchaseSide(color: Colors.green),
//                       shape: RoundedRectangleBPurchase(
//                         bPurchaseRadius: BPurchaseRadius.circular(12),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: const Text(
//                       'RePurchase',
//                       style: TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//               ],
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: RoundedRectangleBPurchase(
//                       bPurchaseRadius: BPurchaseRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'View Details',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:ica_app/src/cores/components/buttons/w_button_inkwell.dart';
import 'package:ica_app/src/cores/themes/app_colors.dart';


class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Cart',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFE8F5E9),
      ),
      home: const MyCartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyCartScreen extends StatefulWidget {
  const MyCartScreen({Key? key}) : super(key: key);

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  final List<CartItem> cartItems = [
    CartItem(
      name: 'Almonds',
      price: 150.000,
      weight: 10.00,
      quantity: 2,
      imageUrl: 'assets/almonds.png',
    ),
    CartItem(
      name: 'Mix dry\nfruits',
      price: 90.000,
      weight: 10.00,
      quantity: 2,
      imageUrl: 'assets/mix_dry_fruits.png',
    ),
    CartItem(
      name: 'Coffee',
      price: 100.000,
      weight: 10.00,
      quantity: 2,
      imageUrl: 'assets/coffee.png',
    ),
  ];

  void _incrementQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5E9),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () {},
          ),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          return CartItemCard(
            item: cartItems[index],
            onIncrement: () => _incrementQuantity(index),
            onDecrement: () => _decrementQuantity(index),
            onRemove: () => _removeItem(index),
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.cyan,
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
                  SizedBox(width: 8),
                  Icon(Icons.send, color: AppColors.colorPurple, size: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem {
  final String name;
  final double price;
  final double weight;
  int quantity;
  final String imageUrl;

  CartItem({
    required this.name,
    required this.price,
    required this.weight,
    required this.quantity,
    required this.imageUrl,
  });
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.price.toStringAsFixed(2)}đ',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.weight.toStringAsFixed(2)}kg',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Controls Column
          Column(
            children: [
              // Delete Button
              //Button(onTap: onRemove),
              const WButtonInkwell(),
              const SizedBox(height: 20),
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onDecrement,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.remove,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 30),
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onIncrement,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}