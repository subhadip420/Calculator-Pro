import 'package:flutter/material.dart';

class UnitSelectorSheet extends StatefulWidget {
  final String category; // 'Length', 'Weight' etc.

  const UnitSelectorSheet({
    super.key,
    required this.category,
  });

  @override
  State<UnitSelectorSheet> createState() => _UnitSelectorSheetState();
}

class _UnitSelectorSheetState extends State<UnitSelectorSheet> {
  final Color bgColor = const Color(0xFF0E131D);
  final Color surfaceColor = const Color(0xFF1E2638);
  final Color cyanColor = const Color(0xFF4CD7F6);
  final Color textGrey = const Color(0xFFDBC2AD);

  // --- UPDATED MASTER DATA STORE (Group-wise) ---
  final Map<String, Map<String, List<Map<String, String>>>> unitData = {
    'Length': {
      'Metric Units': [
        {'name': 'Kilometer', 'symbol': 'km'},
        {'name': 'Meter', 'symbol': 'm'},
        {'name': 'Centimeter', 'symbol': 'cm'},
        {'name': 'Millimeter', 'symbol': 'mm'},
        {'name': 'Micrometer', 'symbol': 'µm'},
        {'name': 'Nanometer', 'symbol': 'nm'},
      ],
      'Imperial Units': [
        {'name': 'Mile', 'symbol': 'mi'},
        {'name': 'Yard', 'symbol': 'yd'},
        {'name': 'Foot', 'symbol': 'ft'},
        {'name': 'Inch', 'symbol': 'in'},
      ],
      'Astronomical': [
        {'name': 'Parsec', 'symbol': 'pc'},
        {'name': 'Light Year', 'symbol': 'ly'},
        {'name': 'Astronomical Unit', 'symbol': 'au'},
      ],
      'Nautical': [
        {'name': 'Nautical Mile', 'symbol': 'NM'},
      ],
    },
    'Weight & Mass': {
      'Metric Units': [
        {'name': 'Tonne', 'symbol': 't'},
        {'name': 'Kilogram', 'symbol': 'kg'},
        {'name': 'Gram', 'symbol': 'g'},
        {'name': 'Milligram', 'symbol': 'mg'},
      ],
      'Imperial Units': [
        {'name': 'Pound', 'symbol': 'lb'},
        {'name': 'Ounce', 'symbol': 'oz'},
      ],
    },
    // Future me Area, Volume etc. add kar sakte hain
  };

  Map<String, List<Map<String, String>>> displayedGroups = {};
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sheet open hote hi us category ka poora grouped data load hoga
    displayedGroups = unitData[widget.category] ?? {};
  }

  // --- SMART SEARCH LOGIC ---
  void _filterUnits(String query) {
    final allGroups = unitData[widget.category] ?? {};

    if (query.isEmpty) {
      setState(() {
        displayedGroups = allGroups;
      });
      return;
    }

    final searchLower = query.toLowerCase();
    Map<String, List<Map<String, String>>> filteredGroups = {};

    // Har group ke andar search karega
    allGroups.forEach((groupName, units) {
      final matchedUnits = units.where((unit) {
        final nameLower = unit['name']!.toLowerCase();
        final symbolLower = unit['symbol']!.toLowerCase();
        return nameLower.contains(searchLower) || symbolLower.contains(searchLower);
      }).toList();

      // Agar is group mein koi match mila, toh hi isko list me dikhayega
      if (matchedUnits.isNotEmpty) {
        filteredGroups[groupName] = matchedUnits;
      }
    });

    setState(() {
      displayedGroups = filteredGroups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80, // Height thodi aur badha di taaki cards acche se dikhein
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. Drag Handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: textGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TextField(
                controller: searchController,
                onChanged: _filterUnits,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: cyanColor,
                decoration: InputDecoration(
                  hintText: 'Search in ${widget.category}',
                  hintStyle: TextStyle(color: textGrey.withOpacity(0.5), fontSize: 15),
                  prefixIcon: Icon(Icons.search_rounded, color: textGrey.withOpacity(0.7)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Group-wise Dynamic List View
          Expanded(
            child: displayedGroups.isEmpty
                ? Center(
              child: Text(
                'No unit found',
                style: TextStyle(color: textGrey.withOpacity(0.5), fontSize: 16),
              ),
            )
                : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: displayedGroups.keys.length,
              itemBuilder: (context, index) {
                String groupName = displayedGroups.keys.elementAt(index);
                List<Map<String, String>> units = displayedGroups[groupName]!;

                return _buildGroupCard(groupName, units);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD UI METHOD ---
  Widget _buildGroupCard(String groupName, List<Map<String, String>> units) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.4), // Card ka background color
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Title (e.g., "Metric Units")
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
            child: Text(
              groupName.toUpperCase(),
              style: TextStyle(
                color: cyanColor.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Units List under this group
          ...units.map((unit) {
            return ListTile(
              onTap: () {
                Navigator.pop(context, unit); // Select karte hi wapas bhej dega
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              leading: CircleAvatar(
                backgroundColor: surfaceColor.withOpacity(0.5),
                radius: 20,
                child: Text(
                  unit['symbol']!,
                  style: TextStyle(color: textGrey, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              title: Text(
                unit['name']!,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }),
          const SizedBox(height: 8), // Bottom padding in card
        ],
      ),
    );
  }
}