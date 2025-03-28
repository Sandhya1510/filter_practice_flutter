import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;//(Used to make API calls.)
import 'dart:convert';//(Converts JSON responses into Dart objects.)

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FilterScreen(),
    );
  }
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? selectedCategory;       //(stores the selected product category.)
  String? selectedBrand;          //(Stores the selected brand.)
  List<dynamic> filteredData = [];  //(Store fetched products)
  List<String> brands = [];         //(Stores available brands based on category.)

  final List<String> categories = ["Smartphones", "Laptops", "Fragrances"];     //(Available options)

  Future<void> fetchBrands() async {                      //(Calls the API when a category is selected.)
    if (selectedCategory == null) return;

    final response = await http.get(
      Uri.parse("https://dummyjson.com/products/category/${selectedCategory!.toLowerCase()}"),
    );

    if (response.statusCode == 200) {
      List<dynamic> products = jsonDecode(response.body)["products"];

      Set<String> brandSet = products.map<String>((product) => product["brand"] as String).toSet();

      setState(() {
        brands = brandSet.toList();
        selectedBrand = null;
      });
    } else {
      throw Exception("Failed to fetch brands");
    }
  }

  // Future<void> fetchData() async {                  //(Fetches products from the selected category.)
  //   if (selectedCategory == null && selectedBrand == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please select both filters", style: TextStyle(color: Colors.redAccent),)),
  //     );
  //     return;
  //   }
  //
  //   final response = await http.get(
  //     Uri.parse("https://dummyjson.com/products/category/${selectedCategory!.toLowerCase()}"),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     List<dynamic> products = jsonDecode(response.body)["products"];
  //
  //     List<dynamic> filteredProducts =
  //     products.where((product) => product["brand"] == selectedBrand).toList();
  //
  //     setState(() {
  //       filteredData = filteredProducts;              //(Updates filteredData to display results.)
  //     });
  //   } else {
  //     throw Exception("Failed to fetch data");
  //   }
  // }

  Future<void> fetchData() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a category", style: TextStyle(color: Colors.redAccent)),
        ),
      );
      return;
    }

    final response = await http.get(
      Uri.parse("https://dummyjson.com/products/category/${selectedCategory!.toLowerCase()}"),
    );

    if (response.statusCode == 200) {
      List<dynamic> products = jsonDecode(response.body)["products"];


      List<dynamic> filteredProducts = selectedBrand == null
          ? products
          : products.where((product) => product["brand"] == selectedBrand).toList();

      setState(() {
        filteredData = filteredProducts; //(Updates filteredData to display results.)
      });
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  void resetFilters() {         //(Clears the selected filters and resets the UI.)
    setState(() {
      selectedCategory = null;
      selectedBrand = null;
      brands = [];
      filteredData =[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Filter App",style: TextStyle(color: Colors.white),),backgroundColor:  Color(0xFF004D40),),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select category",style: TextStyle(fontSize: 20),),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: "Category",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              value: selectedCategory,
              items: categories.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  brands = [];
                  selectedBrand = null;
                });
                fetchBrands();
              },
              dropdownColor: Colors.white,
              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text("select Brand",style: TextStyle(fontSize: 20)),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: "Brand",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              value: selectedBrand,
              items: brands.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: brands.isEmpty ? null : (value) { setState(() {selectedBrand = value;});},
              dropdownColor: Colors.white,
              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: resetFilters,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.red),
                      ),
                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  child: Text("Reset",style: TextStyle(color: Colors.redAccent),),
                ),
                ElevatedButton(
                  onPressed: fetchData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text("Apply",style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: filteredData.isEmpty
                  ? Center(child: Text("No Data Available"))
                  : ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    child: ListTile(
                      leading: Image.network(
                        filteredData[index]["thumbnail"],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(filteredData[index]["title"]),
                      subtitle: Text("Price: \$${filteredData[index]["price"]}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
