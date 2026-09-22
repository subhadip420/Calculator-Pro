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
        {'name': 'Hectometer', 'symbol': 'hm'},
        {'name': 'Decameter', 'symbol': 'dam'},
        {'name': 'Meter', 'symbol': 'm'},
        {'name': 'Decimeter', 'symbol': 'dm'},
        {'name': 'Centimeter', 'symbol': 'cm'},
        {'name': 'Millimeter', 'symbol': 'mm'},
        {'name': 'Micrometer', 'symbol': 'µm'},
        {'name': 'Nanometer', 'symbol': 'nm'},
        {'name': 'Picometer', 'symbol': 'pm'},
      ],
      'Imperial Units': [
        {'name': 'Mil', 'symbol': 'mil'},
        {'name': 'Inch', 'symbol': 'in'},
        {'name': 'Link', 'symbol': 'lk'},
        {'name': 'Foot', 'symbol': 'ft'},
        {'name': 'Yard', 'symbol': 'yd'},
        {'name': 'Rod', 'symbol': 'rd'},
        {'name': 'Chain', 'symbol': 'ch'},
        {'name': 'Furlong', 'symbol': 'fur'},
        {'name': 'Mile', 'symbol': 'mi'},
        {'name': 'League', 'symbol': 'lea'},


      ],
      'Scientific': [
        {'name': 'Bohr radius', 'symbol': 'a0'},
        {'name': 'Angstrom', 'symbol': 'Å'},
      ],

      'Astronomical': [
        {'name': 'Parsec', 'symbol': 'pc'},
        {'name': 'Light year', 'symbol': 'ly'},
        {'name': 'Astronomical unit', 'symbol': 'au'},
      ],
      'Regional': [
        {'name': 'Arabic assba', 'symbol': 'asb'},
        {'name': 'Arabic qabda', 'symbol': 'qbd'},
        {'name': 'Arabic shibr', 'symbol': 'shb'},
        {'name': "Arabic ba'a", 'symbol': 'baa'},
        {'name': 'Arabic qasab', 'symbol': 'qsb'},
        {'name': 'Arabic farsakh', 'symbol': 'fsk'},
        {'name': 'Arabic marhala', 'symbol': 'mrh'},

        {'name': 'Chinese cum', 'symbol': 'cum'},
        {'name': 'Chinese chi', 'symbol': 'chi'},
        {'name': 'Chinese zhang', 'symbol': 'zhg'},
        {'name': 'Chinese li', 'symbol': 'li'},

        {'name': 'German linie', 'symbol': 'lin'},
        {'name': 'German zoll', 'symbol': 'zoll'},
        {'name': 'German elle', 'symbol': 'elle'},
        {'name': 'German klafter', 'symbol': 'klft'},
        {'name': 'German rute', 'symbol': 'rute'},
        {'name': 'German meile', 'symbol': 'dmi'},

        {'name': 'Indian angula', 'symbol': 'ang'},
        {'name': 'Indian hasta', 'symbol': 'hst'},
        {'name': 'Indian dhira', 'symbol': 'dhr'},
        {'name': 'Indian gaz', 'symbol': 'gaz'},
        {'name': 'Indian kos', 'symbol': 'kos'},
        {'name': 'Indian yojana', 'symbol': 'yoj'},

        {'name': 'Italian palmo', 'symbol': 'plmo'},

        {'name': 'Japanese sun', 'symbol': 'sun'},
        {'name': 'Japanese shaku', 'symbol': 'sha'},
        {'name': 'Japanese ken', 'symbol': 'ken'},
        {'name': 'Japanese ri', 'symbol': 'ri'},

        {'name': 'Korean pun', 'symbol': 'pun'},
        {'name': 'Korean chon', 'symbol': 'chon'},
        {'name': 'Korean ja', 'symbol': 'ja'},
        {'name': 'Korean gan', 'symbol': 'gan'},
        {'name': 'Korean jeong', 'symbol': 'jeong'},
        {'name': 'Korean ri', 'symbol': 'kri'},

        {'name': 'Persian zar', 'symbol': 'zar'},
        {'name': 'Persian farsang', 'symbol': 'frsg'},
        {'name': 'Portuguese braça', 'symbol': 'brca'},
        {'name': 'Russian vershok', 'symbol': 'vrsh'},
        {'name': 'Russian arshin', 'symbol': 'arsh'},
        {'name': 'Russian sazhen', 'symbol': 'saz'},
        {'name': 'Russian verst', 'symbol': 'vst'},
        {'name': 'Scandinavian mile', 'symbol': 'smi'},
        {'name': 'Spanish vara', 'symbol': 'vara'},
        {'name': 'Spanish legua', 'symbol': 'lgua'},
        {'name': 'Thai wah', 'symbol': 'wah'},
        {'name': 'Thai sen', 'symbol': 'sen'},
        {'name': 'Thai yote', 'symbol': 'yot'},
        {'name': 'Turkish parmak', 'symbol': 'prm'},
        {'name': 'Turkish endaze', 'symbol': 'endz'},
        {'name': 'Turkish arşın', 'symbol': 'arsn'},
        {'name': 'Turkish kulaç', 'symbol': 'kulc'},
      ],

      'Historical': [
        {'name': 'Biblical etzba (finger)', 'symbol': 'etz'},
        {'name': 'Biblical zereth (span)', 'symbol': 'zrt'},
        {'name': 'Biblical ammah (cubit)', 'symbol': 'amh'},
        {'name': 'Biblical qaneh (reed)', 'symbol': 'qnh'},
        {'name': 'Egyptian cubit', 'symbol': 'cbt'},
        {'name': 'English ell', 'symbol': 'ell'},
        {'name': 'Greek daktylos (finger)', 'symbol': 'dkty'},
        {'name': 'Greek palaiste (palm)', 'symbol': 'plst'},
        {'name': 'Greek pous (foot)', 'symbol': 'pous'},
        {'name': 'Greek pechys (cubit)', 'symbol': 'pchy'},
        {'name': 'Greek orgyia (fathom)', 'symbol': 'orga'},
        {'name': 'Greek plethron', 'symbol': 'plth'},
        {'name': 'Greek stadion', 'symbol': 'stad'},
        {'name': 'Roman digitus (finger)', 'symbol': 'dgts'},
        {'name': 'Roman palmus (palm)', 'symbol': 'plms'},
        {'name': 'Roman pes (foot)', 'symbol': 'pes'},
        {'name': 'Roman cubitus (cubit)', 'symbol': 'cubi'},
        {'name': 'Roman pace', 'symbol': 'pace'},
        {'name': 'Roman actus', 'symbol': 'actu'},
        {'name': 'Roman mile', 'symbol': 'rmi'},
      ],

      'Others': [
        {'name': 'Cable Length', 'symbol': 'cbl'},
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