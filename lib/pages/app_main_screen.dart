import 'package:flutter/material.dart';
import 'package:flutterproject/colors.dart';
import 'package:flutterproject/models/api_coffee_model.dart';
import 'package:flutterproject/pages/home_screen.dart';

class CoffeeAppMainScreen extends StatefulWidget {
  const CoffeeAppMainScreen({super.key});

  @override
  State<CoffeeAppMainScreen> createState() => _CoffeeAppMainScreenState();
}

class _CoffeeAppMainScreenState extends State<CoffeeAppMainScreen> {
  int indexMenu = 0;

  final List<ApiCoffee> favoriteItems = [];
  final List<ApiCoffee> cartItems = [];

  final List<String> notifications = [
    'Yeni kampanya: Tüm latte çeşitlerinde %20 indirim!',
    'Flat White bugün en çok tercih edilen kahve oldu.',
    'Sepetindeki ürünler seni bekliyor.',
    'İstanbul şubemizde sıcak içeceklerde özel fırsatlar var.',
  ];

  void toggleFavorite(ApiCoffee coffee) {
    setState(() {
      if (favoriteItems.any((item) => item.id == coffee.id)) {
        favoriteItems.removeWhere((item) => item.id == coffee.id);
      } else {
        favoriteItems.add(coffee);
      }
    });
  }

  void addToCart(ApiCoffee coffee) {
    setState(() {
      cartItems.add(coffee);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${coffee.title} sepete eklendi'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void removeFromCart(ApiCoffee coffee) {
    setState(() {
      cartItems.removeWhere((item) => item.id == coffee.id);
    });
  }

  void removeFromFavorite(ApiCoffee coffee) {
    setState(() {
      favoriteItems.removeWhere((item) => item.id == coffee.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CoffeeAppHomeScreen(
        favoriteItems: favoriteItems,
        cartItems: cartItems,
        onToggleFavorite: toggleFavorite,
        onAddToCart: addToCart,
        onTabChange: (index) {
          setState(() {
            indexMenu = index;
          });
        },
      ),
      FavoritePage(
        favoriteItems: favoriteItems,
        onRemoveFavorite: removeFromFavorite,
        onGoHome: () {
          setState(() {
            indexMenu = 0;
          });
        },
      ),
      CartPage(
        cartItems: cartItems,
        onRemoveCart: removeFromCart,
        onGoHome: () {
          setState(() {
            indexMenu = 0;
          });
        },
      ),
      NotificationPage(
        notifications: notifications,
        onGoHome: () {
          setState(() {
            indexMenu = 0;
          });
        },
      ),
    ];

    return PopScope(
      canPop: indexMenu == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && indexMenu != 0) {
          setState(() {
            indexMenu = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: xbackgroundColor,
        body: IndexedStack(
          index: indexMenu,
          children: screens,
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(4, (index) {
                final items = [
                  {'icon': Icons.home_rounded, 'label': 'Ana Sayfa'},
                  {'icon': Icons.favorite_rounded, 'label': 'Favoriler'},
                  {'icon': Icons.shopping_bag_rounded, 'label': 'Sepet'},
                  {'icon': Icons.notifications_rounded, 'label': 'Bildirim'},
                ];

                final bool isActive = indexMenu == index;

                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      setState(() {
                        indexMenu = index;
                      });
                    },
                    child: SizedBox(
                      height: 70,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
                          Icon(
                            items[index]['icon'] as IconData,
                            color: isActive ? xprimaryColor : xsecondaryColor,
                            size: 25,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            items[index]['label'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  isActive ? xprimaryColor : xsecondaryColor,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isActive)
                            Container(
                              height: 4,
                              width: 18,
                              decoration: BoxDecoration(
                                color: xprimaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  final List<ApiCoffee> favoriteItems;
  final Function(ApiCoffee) onRemoveFavorite;
  final VoidCallback onGoHome;

  const FavoritePage({
    super.key,
    required this.favoriteItems,
    required this.onRemoveFavorite,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: favoriteItems.isEmpty
          ? emptyState(
              icon: Icons.favorite_border,
              title: 'Favorilerin boş',
              subtitle: 'Beğendiğin kahveler burada görünecek.',
              buttonText: 'Ana Sayfaya Dön',
              onPressed: onGoHome,
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Favoriler',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ...favoriteItems.map(
                  (coffee) => Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          coffee.image,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 55,
                            height: 55,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      title: Text(coffee.title),
                      subtitle: Text(coffee.isHot ? 'Sıcak' : 'Soğuk'),
                      trailing: IconButton(
                        onPressed: () => onRemoveFavorite(coffee),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class CartPage extends StatelessWidget {
  final List<ApiCoffee> cartItems;
  final Function(ApiCoffee) onRemoveCart;
  final VoidCallback onGoHome;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onRemoveCart,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final total = cartItems.fold<double>(
      0,
      (sum, item) => sum + ((item.id % 7) + 3.99),
    );

    return SafeArea(
      child: cartItems.isEmpty
          ? emptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Sepetin boş',
              subtitle: 'Sepete eklediğin ürünler burada listelenecek.',
              buttonText: 'Kahveleri Gör',
              onPressed: onGoHome,
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Sepetim',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ...cartItems.map(
                  (coffee) => Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          coffee.image,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 55,
                            height: 55,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      title: Text(coffee.title),
                      subtitle: Text(
                        '\$${((coffee.id % 7) + 3.99).toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        onPressed: () => onRemoveCart(coffee),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Toplam',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}

class NotificationPage extends StatelessWidget {
  final List<String> notifications;
  final VoidCallback onGoHome;

  const NotificationPage({
    super.key,
    required this.notifications,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: notifications.isEmpty
          ? emptyState(
              icon: Icons.notifications_none,
              title: 'Bildirim yok',
              subtitle: 'Yeni kampanyalar burada görünecek.',
              buttonText: 'Ana Sayfaya Dön',
              onPressed: onGoHome,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Bildirimler',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                final item = notifications[index - 1];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.notifications),
                    ),
                    title: const Text('Kahve Dükkanı'),
                    subtitle: Text(item),
                  ),
                );
              },
            ),
    );
  }
}

Widget emptyState({
  required IconData icon,
  required String title,
  required String subtitle,
  required String buttonText,
  required VoidCallback onPressed,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 70, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          )
        ],
      ),
    ),
  );
}