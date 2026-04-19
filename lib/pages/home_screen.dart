import 'package:flutter/material.dart';
import 'package:flutterproject/colors.dart';
import 'package:flutterproject/models/api_coffee_model.dart';
import 'package:flutterproject/pages/coffee_detai_screen.dart';
import 'package:flutterproject/services/coffee_service.dart';

class CoffeeAppHomeScreen extends StatefulWidget {
  final List<ApiCoffee> favoriteItems;
  final List<ApiCoffee> cartItems;
  final Function(ApiCoffee) onToggleFavorite;
  final Function(ApiCoffee) onAddToCart;
  final Function(int) onTabChange;

  const CoffeeAppHomeScreen({
    super.key,
    required this.favoriteItems,
    required this.cartItems,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onTabChange,
  });

  @override
  State<CoffeeAppHomeScreen> createState() => _CoffeeAppHomeScreenState();
}

class _CoffeeAppHomeScreenState extends State<CoffeeAppHomeScreen> {
  final CoffeeService service = CoffeeService();

  int selectedIndex = 0;
  String searchText = '';
  String selectedSort = 'Popüler';

  List<ApiCoffee> allCoffee = [];
  bool isLoading = true;
  String errorMessage = '';

  final List<String> categoryTabs = ['Tümü', 'Sıcak', 'Soğuk'];

  @override
  void initState() {
    super.initState();
    fetchCoffee();
  }

  Future<void> fetchCoffee() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await service.fetchAllCoffee();
      setState(() {
        allCoffee = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Veriler yüklenirken hata oluştu.';
        isLoading = false;
      });
    }
  }

  List<ApiCoffee> get filteredCoffee {
    List<ApiCoffee> result = allCoffee.where((coffee) {
      final query = searchText.toLowerCase().trim();

      final matchesSearch =
          coffee.title.toLowerCase().contains(query) ||
          coffee.description.toLowerCase().contains(query);

      final selectedCategory = categoryTabs[selectedIndex];
      final matchesCategory = selectedCategory == 'Tümü' ||
          (selectedCategory == 'Sıcak' && coffee.isHot) ||
          (selectedCategory == 'Soğuk' && !coffee.isHot);

      return matchesSearch && matchesCategory;
    }).toList();

    if (selectedSort == 'A-Z') {
      result.sort((a, b) => a.title.compareTo(b.title));
    } else if (selectedSort == 'Puan') {
      result.sort((a, b) => b.id.compareTo(a.id));
    }

    return result;
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final options = ['Popüler', 'A-Z', 'Puan'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
                final isSelected = selectedSort == option;
                return ListTile(
                  title: Text(option),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedSort = option;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;
    final coffees = filteredCoffee;

    return RefreshIndicator(
      onRefresh: fetchCoffee,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xff111111),
                      Color(0xff313131),
                    ],
                  ),
                ),
              ),
              headerParts(),
            ],
          ),
          const SizedBox(height: 28),
          categorySelection(),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Önerilen Kahveler',
                    style: TextStyle(
                      fontSize: isWide ? 22 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Sıralama: $selectedSort',
                  style: TextStyle(color: xsecondaryColor, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(errorMessage),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: fetchCoffee,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            )
          else if (coffees.isEmpty)
            const Padding(
              padding: EdgeInsets.all(25),
              child: Center(
                child: Text('Sonuç bulunamadı'),
              ),
            )
          else
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 3 : 2,
                mainAxisExtent: isWide ? 310 : 285,
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
              ),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: coffees.length,
              itemBuilder: (context, index) {
                final coffee = coffees[index];
                final isFavorite = widget.favoriteItems
                    .any((item) => item.id == coffee.id);

                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CoffeeDetaiScreen(
                          coffee: coffee,
                          isFavorite: isFavorite,
                        ),
                      ),
                    );

                    if (result is Map) {
                      if (result['action'] == 'favorite') {
                        widget.onToggleFavorite(coffee);
                      } else if (result['action'] == 'cart') {
                        widget.onAddToCart(coffee);
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                coffee.image,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 160,
                                  width: double.infinity,
                                  color: Colors.grey.shade300,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.25),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(25),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Colors.amber,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "4.8",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          coffee.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          coffee.isHot ? 'Sıcak Kahve' : 'Soğuk Kahve',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: xsecondaryColor),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '\$${((coffee.id % 7) + 3.99).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => widget.onToggleFavorite(coffee),
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => widget.onAddToCart(coffee),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: xprimaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Padding headerParts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Konum",
                      style: TextStyle(color: xsecondaryColor),
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "İstanbul, Türkiye",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: xsecondaryColor,
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => widget.onTabChange(2),
                    icon: const Icon(Icons.shopping_bag, color: Colors.white),
                  ),
                  if (widget.cartItems.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: xprimaryColor,
                        child: Text(
                          '${widget.cartItems.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xff2a2a2a),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0),
                            isDense: true,
                            border: InputBorder.none,
                            hintText: "Kahve ara",
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: xsecondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: showFilterBottomSheet,
                child: Container(
                  height: 60,
                  width: 55,
                  decoration: BoxDecoration(
                    color: xprimaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.tune,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              "assets/coffee-shop/banner.png",
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  SizedBox categorySelection() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        itemCount: categoryTabs.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 25 : 10,
                right: index == categoryTabs.length - 1 ? 25 : 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? xprimaryColor
                    : xsecondaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: Text(
                categoryTabs[index],
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}