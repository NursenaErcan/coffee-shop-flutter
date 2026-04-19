import 'package:flutter/material.dart';
import 'package:flutterproject/colors.dart';
import 'package:flutterproject/models/api_coffee_model.dart';
import 'package:flutterproject/pages/api_coffee_detail_screen.dart';
import 'package:flutterproject/services/coffee_service.dart';

class ApiCoffeeScreen extends StatefulWidget {
  const ApiCoffeeScreen({super.key});

  @override
  State<ApiCoffeeScreen> createState() => _ApiCoffeeScreenState();
}

class _ApiCoffeeScreenState extends State<ApiCoffeeScreen> {
  final CoffeeService service = CoffeeService();
  List<ApiCoffee> allCoffee = [];
  List<ApiCoffee> filteredCoffee = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchText = '';
  String selectedFilter = 'Tümü';

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
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Veriler yüklenirken hata oluştu.';
        isLoading = false;
      });
    }
  }

  void applyFilters() {
    List<ApiCoffee> result = allCoffee.where((coffee) {
      final query = searchText.toLowerCase().trim();
      final matchesSearch =
          coffee.title.toLowerCase().contains(query) ||
          coffee.description.toLowerCase().contains(query);

      final matchesFilter = selectedFilter == 'Tümü' ||
          (selectedFilter == 'Sıcak' && coffee.isHot) ||
          (selectedFilter == 'Soğuk' && !coffee.isHot);

      return matchesSearch && matchesFilter;
    }).toList();

    filteredCoffee = result;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 700;

    return Scaffold(
      backgroundColor: xbackgroundColor,
      appBar: AppBar(
        title: const Text('Kahve API Demo'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchCoffee,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  applyFilters();
                });
              },
              decoration: InputDecoration(
                hintText: 'Kahve ara...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: ['Tümü', 'Sıcak', 'Soğuk'].map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filter;
                        applyFilters();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 80),
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(errorMessage),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: fetchCoffee,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              )
            else if (filteredCoffee.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(
                  child: Text('Sonuç bulunamadı'),
                ),
              )
            else
              GridView.builder(
                itemCount: filteredCoffee.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: isWide ? 310 : 280,
                ),
                itemBuilder: (context, index) {
                  final coffee = filteredCoffee[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApiCoffeeDetailScreen(coffee: coffee),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                coffee.image,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade300,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            coffee.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            coffee.isHot ? 'Sıcak Kahve' : 'Soğuk Kahve',
                            style: TextStyle(color: xsecondaryColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}