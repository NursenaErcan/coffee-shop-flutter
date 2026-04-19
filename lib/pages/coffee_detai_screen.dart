import 'package:flutter/material.dart';
import 'package:flutterproject/Widgets/common_button.dart';
import 'package:flutterproject/colors.dart';
import 'package:flutterproject/models/api_coffee_model.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';

class CoffeeDetaiScreen extends StatefulWidget {
  final ApiCoffee coffee;
  final bool isFavorite;

  const CoffeeDetaiScreen({
    super.key,
    required this.coffee,
    this.isFavorite = false,
  });

  @override
  State<CoffeeDetaiScreen> createState() => _CoffeeDetaiScreenState();
}

class _CoffeeDetaiScreenState extends State<CoffeeDetaiScreen> {
  String selectedSize = 'M';
  late bool favorite;

  @override
  void initState() {
    super.initState();
    favorite = widget.isFavorite;
  }

  void showFeatureInfo(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 700;

    return Scaffold(
      backgroundColor: xbackgroundColor,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        children: [
          const SizedBox(height: 65),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              const Text(
                "Detay",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    favorite = !favorite;
                  });
                  Navigator.pop(context, {'action': 'favorite'});
                },
                icon: Icon(
                  favorite ? Iconsax.heart5 : Iconsax.heart,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              widget.coffee.image,
              width: double.infinity,
              height: isWide ? 360 : 270,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: isWide ? 360 : 270,
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.coffee.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.coffee.isHot ? 'Sıcak Kahve' : 'Soğuk Kahve',
            style: TextStyle(
              fontSize: 13,
              color: xsecondaryColor,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 5),
              const Text(
                "4.8",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Text(
                " (${widget.coffee.ingredients.length} içerik)",
                style: TextStyle(
                  fontSize: 12,
                  color: xsecondaryColor,
                ),
              )
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              featureButton(
                icon: Icons.delivery_dining,
                label: "Teslimat",
                onTap: () => showFeatureInfo(
                  "Teslimat Bilgisi",
                  "Tahmini teslim süresi 15-20 dakikadır.",
                ),
              ),
              featureButton(
                icon: Icons.coffee,
                label: "İçerik",
                onTap: () => showFeatureInfo(
                  "İçerik Bilgisi",
                  widget.coffee.ingredients.isEmpty
                      ? 'İçerik bilgisi bulunmuyor.'
                      : widget.coffee.ingredients.join(', '),
                ),
              ),
              featureButton(
                icon: Icons.local_cafe,
                label: "Tür",
                onTap: () => showFeatureInfo(
                  "Kahve Türü",
                  widget.coffee.isHot ? 'Sıcak kahve' : 'Soğuk kahve',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(
            indent: 15,
            endIndent: 15,
            color: Colors.black12,
          ),
          const SizedBox(height: 20),
          const Text(
            "Açıklama",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ReadMoreText(
            widget.coffee.description.isEmpty
                ? 'Bu kahve için açıklama bulunmuyor.'
                : widget.coffee.description,
            trimLength: 125,
            trimMode: TrimMode.Length,
            trimCollapsedText: " Devamını oku",
            trimExpandedText: " Daha az göster",
            style: TextStyle(
              fontSize: 15,
              color: xsecondaryColor,
            ),
            moreStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: xprimaryColor,
            ),
            lessStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: xprimaryColor,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Boyut",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: ['S', '', 'M', '', 'L'].map((e) {
              if (e == "") return const SizedBox(width: 20);
              bool isSelected = selectedSize == e;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSize = e;
                    });
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? xprimaryColor.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? xprimaryColor : Colors.black12,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      e,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? xprimaryColor : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 25),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Fiyat",
                    style: TextStyle(color: xsecondaryColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${((widget.coffee.id % 7) + 3.99).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: xprimaryColor,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              child: CommonButton(
                title: "Sepete Ekle",
                onTab: () {
                  Navigator.pop(context, {'action': 'cart'});
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget featureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.black12.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 25),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}