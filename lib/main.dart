import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Firestore
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Local imports
import 'chatbot_page.dart';
import 'settings_page.dart';
import 'custom_bottom_navbar.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Talipapa',
      theme: ThemeData(
        primaryColor: kGreen,
        scaffoldBackgroundColor: kLightGray,
        iconTheme: IconThemeData(color: kBlue),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: kBlue),
          bodyMedium: TextStyle(color: kBlue),
        ),
        fontFamily: 'Roboto',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedForecast = "One Week";
  String searchText = "";
  bool isSearching = false; // Track whether the search bar is active
  int? selectedIndex;
  String? selectedSort;
  String? selectedFilter;
  String? selectedCommodity; // Track the selected commodity by its name
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // FocusNode for the search bar

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lists to store commodities
  List<Map<String, dynamic>> commodities = [];
  List<Map<String, dynamic>> filteredCommodities = [];
  List<String> favoriteCommodities = []; // List to store favorite commodities
  List<String> displayedCommoditiesNames = []; // List to manage displayed commodities

  @override
  void initState() {
    super.initState();
    fetchCommodities(); // Fetch data when the widget is initialized
    loadDisplayedCommodities(); // Load displayed commodities from local storage
    loadFavorites(); // Load favorite commodities from persistent storage
    loadState(); // Load saved state (filters, sorts, etc.)
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch commodities and repopulate filteredCommodities
    fetchCommodities();

    // Repopulate filteredCommodities based on the current filter
    setState(() {
      if (selectedFilter == "None" || selectedFilter == null) {
        filteredCommodities = List.from(commodities);
      } else if (selectedFilter == "Favorites") {
        filteredCommodities = commodities
            .where((commodity) => favoriteCommodities.contains(commodity['commodity'].toString()))
            .toList();
      } else {
        filteredCommodities = commodities.where((commodity) {
          final commodityType = commodity['commodity_type']?.toString().toLowerCase() ?? "";
          return commodityType == selectedFilter?.toLowerCase();
        }).toList();
      }
    });
  }

  // Fetch commodities from Firestore
  Future<void> fetchCommodities() async {
    try {
      print("Fetching commodities...");
      final querySnapshot = await _firestore.collection('commodities').get();
      if (querySnapshot.docs.isEmpty) {
        print("⚠️ No commodities found in Firestore.");
      }
      setState(() {
        commodities = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        // Update filteredCommodities based on the current filter
        if (selectedFilter == "None" || selectedFilter == null) {
          filteredCommodities = List.from(commodities);
        } else if (selectedFilter == "Favorites") {
          filteredCommodities = commodities
              .where((commodity) => favoriteCommodities.contains(commodity['commodity'].toString()))
              .toList();
        } else {
          filteredCommodities = commodities.where((commodity) {
            final commodityType = commodity['commodity_type']?.toString().toLowerCase() ?? "";
            return commodityType == selectedFilter?.toLowerCase();
          }).toList();
        }
      });
      print("Commodities: ${commodities.length}");
      print("Filtered Commodities: ${filteredCommodities.length}");
    } catch (e) {
      print("❌ Error fetching commodities: $e");
    }
  }

  // Load displayed commodities from SharedPreferences
  Future<void> loadDisplayedCommodities() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCommodities = prefs.getStringList('displayedCommodities');
    setState(() {
      if (storedCommodities != null) {
        displayedCommoditiesNames = storedCommodities;
        filteredCommodities = commodities
            .where((commodity) => displayedCommoditiesNames.contains(commodity['commodity'].toString()))
            .toList();
      }
    });
  }

  // Save displayed commodities to SharedPreferences
  Future<void> saveDisplayedCommodities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('displayedCommodities', displayedCommoditiesNames);
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteCommodities', favoriteCommodities);
    print("Favorites saved: $favoriteCommodities");
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final storedFavorites = prefs.getStringList('favoriteCommodities');
    setState(() {
      if (storedFavorites != null) {
        favoriteCommodities = storedFavorites;
      }
    });
    print("Favorites loaded: $favoriteCommodities");
  }

  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFilter', selectedFilter ?? "None");
    await prefs.setString('selectedSort', selectedSort ?? "None");
    print("State saved: Filter = $selectedFilter, Sort = $selectedSort");
  }

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFilter = prefs.getString('selectedFilter') == "None" ? null : prefs.getString('selectedFilter');
      selectedSort = prefs.getString('selectedSort') == "None" ? null : prefs.getString('selectedSort');
    });

    // Apply the loaded filter and sort
    if (selectedFilter == null) {
      filteredCommodities = List.from(commodities);
    } else if (selectedFilter == "Favorites") {
      filteredCommodities = commodities
          .where((commodity) => favoriteCommodities.contains(commodity['commodity'].toString()))
          .toList();
    } else {
      filteredCommodities = commodities.where((commodity) {
        final commodityType = commodity['commodity_type']?.toString().toLowerCase() ?? "";
        return commodityType == selectedFilter?.toLowerCase();
      }).toList();
    }

    if (selectedSort == "Name") {
      filteredCommodities.sort((a, b) => a['commodity'].toString().compareTo(b['commodity'].toString()));
    } else if (selectedSort == "Price (Low to High)") {
      filteredCommodities.sort((a, b) {
        double priceA = double.tryParse(a['weekly_average_price'].toString()) ?? 0.0;
        double priceB = double.tryParse(b['weekly_average_price'].toString()) ?? 0.0;
        return priceA.compareTo(priceB);
      });
    } else if (selectedSort == "Price (High to Low)") {
      filteredCommodities.sort((a, b) {
        double priceA = double.tryParse(a['weekly_average_price'].toString()) ?? 0.0;
        double priceB = double.tryParse(b['weekly_average_price'].toString()) ?? 0.0;
        return priceB.compareTo(priceA);
      });
    }

    print("State loaded: Filter = $selectedFilter, Sort = $selectedSort");
  }

  void showFavoritesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Helper to check/uncheck all commodities
            void toggleAllFavorites(bool checkAll) {
              setState(() {
                if (checkAll) {
                  favoriteCommodities = commodities.map((c) => c['commodity'].toString()).toList();
                } else {
                  favoriteCommodities.clear();
                }
              });
              // Save favorites and refresh the list
              saveFavorites();
              this.setState(() {
                if (selectedFilter == "Favorites") {
                  filteredCommodities = commodities
                      .where((commodity) => favoriteCommodities.contains(commodity['commodity'].toString()))
                      .toList();
                }
              });
            }

            return AlertDialog(
              title: Text("Select Favorites"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => toggleAllFavorites(true), // Check all
                          child: Text("Check All"),
                        ),
                        TextButton(
                          onPressed: () => toggleAllFavorites(false), // Uncheck all
                          child: Text("Uncheck All"),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: commodities.map((commodity) {
                            final commodityName = commodity['commodity'].toString();
                            return CheckboxListTile(
                              title: Text(commodityName),
                              value: favoriteCommodities.contains(commodityName),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    favoriteCommodities.add(commodityName);
                                  } else {
                                    favoriteCommodities.remove(commodityName);
                                  }
                                });
                                // Save favorites and refresh the list
                                saveFavorites();
                                this.setState(() {
                                  if (selectedFilter == "Favorites") {
                                    filteredCommodities = commodities
                                        .where((commodity) => favoriteCommodities.contains(commodity['commodity'].toString()))
                                        .toList();
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Helper to check/uncheck all commodities
            void toggleAll(bool checkAll) {
              setState(() {
                if (checkAll) {
                  displayedCommoditiesNames = commodities.map((c) => c['commodity'].toString()).toList();
                } else {
                  displayedCommoditiesNames.clear();
                }
              });
              // Refresh the list after toggling
              this.setState(() {
                filteredCommodities = commodities
                    .where((commodity) => displayedCommoditiesNames.contains(commodity['commodity'].toString()))
                    .toList();
              });
            }

            return AlertDialog(
              title: Text("Manage Commodities"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => toggleAll(true), // Check all
                          child: Text("Check All"),
                        ),
                        TextButton(
                          onPressed: () => toggleAll(false), // Uncheck all
                          child: Text("Uncheck All"),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: commodities.map((commodity) {
                            final commodityName = commodity['commodity'].toString();
                            return CheckboxListTile(
                              title: Text(commodityName),
                              value: displayedCommoditiesNames.contains(commodityName),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    displayedCommoditiesNames.add(commodityName);
                                  } else {
                                    displayedCommoditiesNames.remove(commodityName);
                                  }
                                });
                                // Refresh the list after updating displayed commodities
                                this.setState(() {
                                  filteredCommodities = commodities
                                      .where((commodity) => displayedCommoditiesNames.contains(commodity['commodity'].toString()))
                                      .toList();
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Save the updated list to local storage
                    saveDisplayedCommodities();
                    // Ensure the list is refreshed when the dialog is closed
                    setState(() {
                      filteredCommodities = commodities
                          .where((commodity) => displayedCommoditiesNames.contains(commodity['commodity'].toString()))
                          .toList();
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedCommodities = searchText.isEmpty
        ? filteredCommodities
        : filteredCommodities.where((commodity) {
            return commodity['commodity']
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase());
          }).toList();

    return GestureDetector(
      onTap: () {
        // Dismiss the search bar when tapping outside
        if (_searchFocusNode.hasFocus) {
          FocusScope.of(context).unfocus(); // Close the keyboard
          setState(() {
            isSearching = false; // Revert to the search icon
          });
        }
      },
      behavior: HitTestBehavior.opaque, // Ensure taps outside are detected
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kGreen,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
            children: [
              if (selectedCommodity != null) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(
                    'assets/commodity_images/${selectedCommodity ?? "default"}.png',
                  ),
                ),
                SizedBox(width: 8), // Add spacing between the image and the text
                Expanded( // Ensure the text doesn't overflow
                  child: Text(
                    selectedCommodity!,
                    style: TextStyle(
                      fontFamily: 'CourierPrime',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: kBlue,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle long text gracefully
                  ),
                ),
              ] else ...[
                Text(
                  "Select a Commodity",
                  style: TextStyle(
                    fontFamily: 'CourierPrime',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: kBlue,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (isSearching)
              Container(
                width: MediaQuery.of(context).size.width * 0.3, // Adjusted width for the search bar
                margin: EdgeInsets.only(right: 8),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode, // Attach the FocusNode
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: kBlue, fontSize: 16),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kBlue),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kBlue),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.only(left: 8, bottom: 2), // Adjust padding for better alignment
                  ),
                  style: TextStyle(color: kBlue, fontSize: 16),
                ),
              )
            else
              IconButton(
                icon: Icon(Icons.search, color: kBlue),
                onPressed: () {
                  setState(() {
                    isSearching = true; // Activate the search bar
                  });
                  _searchFocusNode.requestFocus(); // Automatically focus the search bar
                },
              ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: kPink.withOpacity(0.6),
                        blurRadius: 12,
                        offset: Offset(0, 12),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(child: Text("Forecast Graph")),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            "See:",
                            style: TextStyle(
                              fontFamily: 'CourierPrime',
                              fontWeight: FontWeight.bold,
                              color: kBlue,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _forecastButton("One Week"),
                                  _forecastButton("Two Weeks"),
                                  _forecastButton("One Month"),
                                  _forecastButton("Two Months"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Sort by Dropdown
                          Flexible(
                            flex: 1,
                            child: DropdownButton<String>(
                              value: selectedSort,
                              hint: Text(
                                "Sort by",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: kBlue,
                                  fontSize: 12,
                                ),
                              ),
                              items: [
                                "None",
                                "Name",
                                "Price (Low to High)",
                                "Price (High to Low)"
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: kBlue, // Match the color with "Filter by"
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedSort = newValue;

                                  if (newValue == "Name") {
                                    filteredCommodities.sort((a, b) => a['commodity'].toString().compareTo(b['commodity'].toString()));
                                  } else if (newValue == "Price (Low to High)") {
                                    filteredCommodities.sort((a, b) {
                                      double priceA = double.tryParse(a['weekly_average_price'].toString()) ?? 0.0;
                                      double priceB = double.tryParse(b['weekly_average_price'].toString()) ?? 0.0;
                                      return priceA.compareTo(priceB);
                                    });
                                  } else if (newValue == "Price (High to Low)") {
                                    filteredCommodities.sort((a, b) {
                                      double priceA = double.tryParse(a['weekly_average_price'].toString()) ?? 0.0;
                                      double priceB = double.tryParse(b['weekly_average_price'].toString()) ?? 0.0;
                                      return priceB.compareTo(priceA);
                                    });
                                  } else {
                                    filteredCommodities = List.from(commodities);
                                    selectedSort = null;
                                  }
                                });
                              },
                              dropdownColor: Colors.white, // Match the dropdown background color
                              isExpanded: true,
                              menuMaxHeight: 200, // Limit the dropdown height to make it scrollable
                            ),
                          ),
                          SizedBox(width: 8),
                          // Filter by Dropdown
                          Flexible(
                            flex: 1,
                            child: DropdownButton<String>(
                              value: selectedFilter,
                              hint: Text(
                                "Filter by",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: kBlue,
                                  fontSize: 12,
                                ),
                              ),
                              items: [
                                "None",
                                "Favorites",
                                "KADIWA RICE-FOR-ALL",
                                "IMPORTED COMMERCIAL RICE",
                                "LOCAL COMMERCE RICE",
                                "CORN",
                                "FISH",
                                "LIVESTOCK & POULTRY PRODUCTS",
                                "LOWLAND VEGETABLES",
                                "HIGHLAND VEGETABLES",
                                "SPICES",
                                "FRUITS",
                                "OTHER BASIC COMMODITIES"
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: kBlue, // Match the color with "Sort by"
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  if (newValue == "None") {
                                    selectedFilter = null; // Reset to default
                                    filteredCommodities = List.from(commodities); // Show all commodities
                                  } else if (newValue == "Favorites") {
                                    selectedFilter = newValue;
                                    filteredCommodities = commodities
                                        .where((commodity) => favoriteCommodities.contains(commodity['commodity'].toString()))
                                        .toList();
                                  } else {
                                    selectedFilter = newValue;
                                    filteredCommodities = commodities.where((commodity) {
                                      final commodityType = commodity['commodity_type']?.toString().toLowerCase() ?? "";
                                      return commodityType == newValue?.toLowerCase();
                                    }).toList();
                                  }
                                  saveState(); // Save the updated state
                                  print("Filtered Commodities after filter change: ${filteredCommodities.length}");
                                });
                              },
                              dropdownColor: Colors.white,
                              isExpanded: true,
                              menuMaxHeight: 200, // Limit the dropdown height to make it scrollable
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.star, color: kPink),
                            onPressed: showFavoritesDialog,
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: kPink),
                            onPressed: showAddDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: displayedCommodities.isEmpty
                      ? Center(
                          child: Text(
                            "No commodities found.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 70),
                          itemCount: displayedCommodities.length,
                          itemBuilder: (context, index) {
                            final commodity = displayedCommodities[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCommodity = commodity['commodity']; // Update selectedCommodity
                                });
                              },
                              child: _buildCommodityItem(commodity, selectedCommodity == commodity['commodity']),
                            );
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(), // Use the reusable bottom navigation bar
      ),
    );
  }

  Widget _forecastButton(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: selectedForecast == text ? kPink : kDivider),
          backgroundColor: selectedForecast == text ? kPink.withOpacity(0.2) : Colors.transparent,
          minimumSize: Size(60, 28), // Adjusted size for a sleeker look
          padding: EdgeInsets.symmetric(horizontal: 8), // Reduced padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
        ),
        onPressed: () {
          setState(() {
            selectedForecast = text;
          });
        },
        child: Text(
          text,
          style: TextStyle(
            color: selectedForecast == text ? kPink : kBlue,
            fontSize: 12, // Smaller font size
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCommodityItem(Map<String, dynamic> commodity, bool isSelected) {
    final String commodityName = commodity['commodity'] ?? "Unknown Commodity";
    final String unit = commodity['unit'] ?? ""; // e.g., "kg"
    final String commodityType = commodity['commodity_type'] ?? "Unknown Type";
    final String specification = (commodity['specification'] == null || 
                                  commodity['specification'].toString().trim().isEmpty || 
                                  commodity['specification'].toString().toLowerCase() == "none" || 
                                  commodity['specification'].toString().toLowerCase() == "nan")
        ? "-" // Replace empty, "None", or "NaN" with "-"
        : commodity['specification'].toString();

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: 100,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [kGreen, Color(0xFFEBF8BB)],
                stops: [0.0, 0.56],
              )
            : null,
        color: isSelected ? null : Colors.white,
        border: Border(
          top: BorderSide(color: kDivider),
          bottom: BorderSide(color: kDivider),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: Colors.green), // Placeholder for an image
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Commodity name with unit
                  Row(
                    children: [
                      Text(
                        commodityName,
                        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "($unit)", // Unit beside the name
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 12, // Smaller and less prominent
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  // Commodity type and specification logic
                  if (selectedFilter == null || selectedFilter == "None" || selectedFilter == "Favorites" || selectedFilter == "Filter by") ...[
                    Text(
                      "$commodityType · $specification",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12, // Small font size
                        color: Colors.grey,
                      ),
                    ),
                  ] else ...[
                    Text(
                      specification,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12, // Small font size
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 5),
            // Price
            Text(
              "₱${(commodity['weekly_average_price'] is double ? commodity['weekly_average_price'] : double.tryParse(commodity['weekly_average_price'].toString()) ?? 0.0).toStringAsFixed(2)}",
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}