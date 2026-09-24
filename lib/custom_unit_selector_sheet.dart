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
        {'name': 'Picogram', 'symbol': 'pg'},
        {'name': 'Nanogram', 'symbol': 'ng'},
        {'name': 'Microgram', 'symbol': 'μg'},
        {'name': 'Milligram', 'symbol': 'mg'},
        {'name': 'Centigram', 'symbol': 'cg'},
        {'name': 'Decigram', 'symbol': 'dg'},
        {'name': 'Gram', 'symbol': 'g'},
        {'name': 'Decagram', 'symbol': 'dag'},
        {'name': 'Hectogram', 'symbol': 'hg'},
        {'name': 'Kilogram', 'symbol': 'kg'},
        {'name': 'Quintal', 'symbol': 'q'},
        {'name': 'Metric ton', 'symbol': 't'},
      ],
      'Imperial Units': [
        {'name': 'Grain', 'symbol': 'gr'},
        {'name': 'Dram', 'symbol': 'dr'},
        {'name': 'Ounce', 'symbol': 'oz'},
        {'name': 'Pound', 'symbol': 'lb'},
        {'name': 'Stone', 'symbol': 'st'},
        {'name': 'Quarter', 'symbol': 'qr'},
        {'name': 'Short ton', 'symbol': 'st'},
        {'name': 'Long ton', 'symbol': 'lt'},
      ],
      'Scientific Units': [
        {'name': 'Electron mass', 'symbol': 'mₑ'},
        {'name': 'Atomic mass unit', 'symbol': 'u'},
        {'name': 'Dalton', 'symbol': 'Da'},
        {'name': 'Proton mass', 'symbol': 'mₚ'},
        {'name': 'Planck mass', 'symbol': 'mPl'},
      ],
      'Astronomical Units': [
        {'name': 'Earth mass', 'symbol': 'M⊕'},
        {'name': 'Solar mass', 'symbol': 'M⊙'},
      ],
      'Regional Units': [
        {'name': 'Arabic dirham', 'symbol': 'drm'},
        {'name': 'Arabic mithqal', 'symbol': 'mthq'},
        {'name': 'Arabic ratl', 'symbol': 'ratl'},
        {'name': 'Chinese fen', 'symbol': 'fen'},
        {'name': 'Chinese qian', 'symbol': 'qian'},
        {'name': 'Chinese liang', 'symbol': 'liang'},
        {'name': 'Chinese jin', 'symbol': 'jin'},
        {'name': 'Chinese dan', 'symbol': 'dan'},
        {'name': 'German pfund', 'symbol': 'pfd'},
        {'name': 'German zentner', 'symbol': 'ztnr'},
        {'name': 'Indian ratti', 'symbol': 'ratti'},
        {'name': 'Indian masha', 'symbol': 'msha'},
        {'name': 'Indian tola', 'symbol': 'tola'},
        {'name': 'Indian pala', 'symbol': 'pala'},
        {'name': 'Indian chatak', 'symbol': 'chtk'},
        {'name': 'Indian seer', 'symbol': 'seer'},
        {'name': 'Indian maund', 'symbol': 'maund'},
        {'name': 'Japanese fun', 'symbol': 'fun'},
        {'name': 'Japanese momme', 'symbol': 'mom'},
        {'name': 'Japanese ryō', 'symbol': 'ryō'},
        {'name': 'Japanese kin', 'symbol': 'kin'},
        {'name': 'Japanese kan', 'symbol': 'kan'},
        {'name': 'Korean don', 'symbol': 'don'},
      ],
      'Historical Units': [
        {'name': 'Babylonian shekel', 'symbol': 'shkl'},
        {'name': 'Babylonian mina', 'symbol': 'mina'},
        {'name': 'Babylonian talent', 'symbol': 'tal'},
        {'name': 'Biblical gerah', 'symbol': 'gerah'},
        {'name': 'Biblical bekah', 'symbol': 'bekah'},
        {'name': 'Biblical pim', 'symbol': 'pim'},
        {'name': 'Biblical shekel', 'symbol': 'shkl'},
        {'name': 'Biblical mina', 'symbol': 'mina'},
        {'name': 'Biblical talent', 'symbol': 'tal'},
        {'name': 'Byzantine nomisma', 'symbol': 'nom'},
        {'name': 'Byzantine litra', 'symbol': 'litra'},
        {'name': 'Egyptian qedet', 'symbol': 'qedet'},
        {'name': 'Egyptian deben', 'symbol': 'deben'},
        {'name': 'Greek obol', 'symbol': 'obol'},
        {'name': 'Greek drachma', 'symbol': 'drch'},
        {'name': 'Greek stater', 'symbol': 'stat'},
        {'name': 'Greek mina', 'symbol': 'mina'},
        {'name': 'Greek talent', 'symbol': 'tal'},
        {'name': 'Medieval mark', 'symbol': 'mark'},
        {'name': 'Roman siliqua', 'symbol': 'slq'},
        {'name': 'Roman scripulum', 'symbol': 'scrp'},
        {'name': 'Roman semiuncia', 'symbol': 'semi'},
        {'name': 'Roman uncia', 'symbol': 'uncia'},
        {'name': 'Roman libra', 'symbol': 'libra'},
      ],
      'Other Units': [
        {'name': 'Carat', 'symbol': 'ct'},
        {'name': 'Pennyweight', 'symbol': 'dwt'},
        {'name': 'Troy ounce', 'symbol': 'ozt'},
      ],
    },
    'Area': {
      'Metric Units': [
        {'name': 'Picometer²', 'symbol': 'pm²'},
        {'name': 'Nanometer²', 'symbol': 'nm²'},
        {'name': 'Micrometer²', 'symbol': 'μm²'},
        {'name': 'Millimeter²', 'symbol': 'mm²'},
        {'name': 'Centimeter²', 'symbol': 'cm²'},
        {'name': 'Decimeter²', 'symbol': 'dm²'},
        {'name': 'Meter²', 'symbol': 'm²'}, // Added base unit
        {'name': 'Decameter²', 'symbol': 'dam²'},
        {'name': 'Are', 'symbol': 'a'},
        {'name': 'Hectometer²', 'symbol': 'hm²'},
        {'name': 'Kilometer²', 'symbol': 'km²'},
      ],
      'Imperial Units': [
        {'name': 'Mil²', 'symbol': 'mil²'},
        {'name': 'Inch²', 'symbol': 'in²'},
        {'name': 'Foot²', 'symbol': 'ft²'}, // Added base unit
        {'name': 'Yard²', 'symbol': 'yd²'},
        {'name': 'Link²', 'symbol': 'li²'},
        {'name': 'Rod²', 'symbol': 'rd²'},
        {'name': 'Chain²', 'symbol': 'ch²'},
        {'name': 'Furlong²', 'symbol': 'fur²'},
        {'name': 'Mile²', 'symbol': 'mi²'},
        {'name': 'Rood', 'symbol': 'ro'},
        {'name': 'Acre', 'symbol': 'ac'},
        {'name': 'Homestead', 'symbol': 'htd'},
        {'name': 'Section', 'symbol': 'sec'},
        {'name': 'Township', 'symbol': 'twp'},
      ],
      'Scientific Units': [
        {'name': 'Planck area', 'symbol': 'lP²'},
        {'name': 'Barn', 'symbol': 'b'},
        {'name': 'Angstrom²', 'symbol': 'Å²'},
      ],
      'Regional Units': [
        {'name': 'Afghan jerib', 'symbol': 'jrb'},
        {'name': 'Central American manzana', 'symbol': 'mzn'},
        {'name': 'Chinese mǔ', 'symbol': 'mǔ'},
        {'name': 'Egyptian feddan', 'symbol': 'fed'},
        {'name': 'Greek stremma', 'symbol': 'strm'},
        {'name': 'Indian cent', 'symbol': 'cent'},
        {'name': 'Indian kottah', 'symbol': 'kott'},
        {'name': 'Indian guntha', 'symbol': 'gnth'},
        {'name': 'Indian ground', 'symbol': 'grnd'},
        {'name': 'Indian bigha', 'symbol': 'bgha'},
        {'name': 'Japanese tatami', 'symbol': 'jō'},
        {'name': 'Japanese tsubo', 'symbol': 'tsbo'},
        {'name': 'Japanese se', 'symbol': 'se'},
        {'name': 'Japanese tan', 'symbol': 'tan'},
        {'name': 'Japanese chō', 'symbol': 'chō'},
        {'name': 'Korean pyeong', 'symbol': 'py'},
        {'name': 'Middle Eastern dunam', 'symbol': 'duna'},
        {'name': 'Pakistani marla', 'symbol': 'marl'},
        {'name': 'Pakistani kanal', 'symbol': 'knal'},
        {'name': 'Puerto Rican cuerda', 'symbol': 'cda'},
        {'name': 'Russian desyatina', 'symbol': 'dsy'},
        {'name': 'South African morgen', 'symbol': 'mgn'},
        {'name': 'Spanish fanegada', 'symbol': 'fng'},
        {'name': 'Thai rai', 'symbol': 'rai'},
      ],
      'Historical Units': [
        {'name': 'Egyptian aroura', 'symbol': 'aro'},
        {'name': 'French arpent', 'symbol': 'arp'},
        {'name': 'Greek plethron', 'symbol': 'plt'},
        {'name': 'Roman actus quadratus', 'symbol': 'act'},
        {'name': 'Roman jugerum', 'symbol': 'jug'},
        {'name': 'Roman heredium', 'symbol': 'hrd'},
      ],
    },
    'Volume': {
      'Standard Units (Liters)': [
        {'name': 'Picoliter', 'symbol': 'pl'},
        {'name': 'Nanoliter', 'symbol': 'nl'},
        {'name': 'Microliter', 'symbol': 'μl'},
        {'name': 'Milliliter', 'symbol': 'ml'},
        {'name': 'Centiliter', 'symbol': 'cl'},
        {'name': 'Deciliter', 'symbol': 'dl'},
        {'name': 'Liter', 'symbol': 'l'},
        {'name': 'Decaliter', 'symbol': 'dal'},
        {'name': 'Hectoliter', 'symbol': 'hl'},
        {'name': 'Kiloliter', 'symbol': 'kl'},
      ],
      'Metric Units (Cubic)': [
        {'name': 'Picometer³', 'symbol': 'pm³'},
        {'name': 'Nanometer³', 'symbol': 'nm³'},
        {'name': 'Micrometer³', 'symbol': 'μm³'},
        {'name': 'Millimeter³', 'symbol': 'mm³'},
        {'name': 'Centimeter³', 'symbol': 'cm³'},
        {'name': 'Decimeter³', 'symbol': 'dm³'},
        {'name': 'Meter³', 'symbol': 'm³'},
        {'name': 'Decameter³', 'symbol': 'dam³'},
        {'name': 'Hectometer³', 'symbol': 'hm³'},
        {'name': 'Kilometer³', 'symbol': 'km³'},
      ],
      'Imperial Units (Cubic)': [
        {'name': 'Mil³', 'symbol': 'mil³'},
        {'name': 'Inch³', 'symbol': 'in³'},
        {'name': 'Link³', 'symbol': 'lnk³'},
        {'name': 'Foot³', 'symbol': 'ft³'},
        {'name': 'Yard³', 'symbol': 'yd³'},
        {'name': 'Rod³', 'symbol': 'rd³'},
        {'name': 'Chain³', 'symbol': 'ch³'},
        {'name': 'Furlong³', 'symbol': 'fur³'},
        {'name': 'Mile³', 'symbol': 'mi³'},
      ],
      'Scientific & Engineering': [
        {'name': 'Planck volume', 'symbol': 'ℓp³'},
        {'name': 'Lambda', 'symbol': 'λ'},
        {'name': 'Oil barrel', 'symbol': 'bbl'},
        {'name': 'Register ton', 'symbol': 'RT'},
        {'name': 'Acre foot', 'symbol': 'ac·ft'},
      ],
      'US Units': [
        {'name': 'Minim (US)', 'symbol': 'min'},
        {'name': 'Fluid dram (US)', 'symbol': 'fl dr'},
        {'name': 'Teaspoon (US)', 'symbol': 'tsp'},
        {'name': 'Tablespoon (US)', 'symbol': 'tbsp'},
        {'name': 'Ounce (US)', 'symbol': 'oz'},
        {'name': 'Gill (US)', 'symbol': 'gi'},
        {'name': 'Cup (US)', 'symbol': 'c'},
        {'name': 'Pint (US)', 'symbol': 'pt'},
        {'name': 'Quart (US)', 'symbol': 'qt'},
        {'name': 'Gallon (US)', 'symbol': 'gal'},
        {'name': 'Dry pint (US)', 'symbol': 'd pt'},
        {'name': 'Dry quart (US)', 'symbol': 'd qt'},
        {'name': 'Dry gallon (US)', 'symbol': 'd gal'},
        {'name': 'Peck (US)', 'symbol': 'pk'},
        {'name': 'Bushel (US)', 'symbol': 'bu'},
        {'name': 'Beer barrel (US)', 'symbol': 'bbl'},
      ],
      'UK Units': [
        {'name': 'Minim (UK)', 'symbol': 'min'},
        {'name': 'Fluid dram (UK)', 'symbol': 'fl dr'},
        {'name': 'Teaspoon (UK)', 'symbol': 'tsp'},
        {'name': 'Tablespoon (UK)', 'symbol': 'tbsp'},
        {'name': 'Ounce (UK)', 'symbol': 'oz'},
        {'name': 'Gill (UK)', 'symbol': 'gi'},
        {'name': 'Cup (UK)', 'symbol': 'c'},
        {'name': 'Pint (UK)', 'symbol': 'pt'},
        {'name': 'Quart (UK)', 'symbol': 'qt'},
        {'name': 'Gallon (UK)', 'symbol': 'gal'},
        {'name': 'Peck (UK)', 'symbol': 'pk'},
        {'name': 'Bushel (UK)', 'symbol': 'bu'},
      ],
      'Regional Units': [
        {'name': 'Arabic mudd', 'symbol': 'mudd'},
        {'name': 'Arabic qist', 'symbol': 'qist'},
        {'name': 'Arabic sa\'', 'symbol': 'sa\''},
        {'name': 'Arabic wasq', 'symbol': 'wasq'},
        {'name': 'Australian tablespoon', 'symbol': 'tbsp'},
        {'name': 'Chinese shao', 'symbol': 'shao'},
        {'name': 'Chinese ge', 'symbol': 'ge'},
        {'name': 'Chinese sheng', 'symbol': 'sheng'},
        {'name': 'Chinese dou', 'symbol': 'dou'},
        {'name': 'Chinese dan', 'symbol': 'dan'},
        {'name': 'German maß', 'symbol': 'maß'},
        {'name': 'Indian pav', 'symbol': 'pav'},
        {'name': 'Indian seer', 'symbol': 'seer'},
        {'name': 'Indian maund', 'symbol': 'maund'},
        {'name': 'Japanese gō', 'symbol': 'gō'},
        {'name': 'Japanese cup', 'symbol': 'c'},
        {'name': 'Japanese shō', 'symbol': 'shō'},
        {'name': 'Japanese to', 'symbol': 'to'},
        {'name': 'Japanese koku', 'symbol': 'koku'},
        {'name': 'Korean hop', 'symbol': 'hop'},
        {'name': 'Korean doe', 'symbol': 'doe'},
        {'name': 'Korean mal', 'symbol': 'mal'},
        {'name': 'Russian charka', 'symbol': 'chrka'},
        {'name': 'Russian shtof', 'symbol': 'shtof'},
        {'name': 'Russian chetvert', 'symbol': 'chetv'},
        {'name': 'Russian vedro', 'symbol': 'vedro'},
        {'name': 'Russian bochka', 'symbol': 'bchka'},
        {'name': 'Spanish arroba', 'symbol': '@'},
        {'name': 'Thai tanan', 'symbol': 'tanan'},
        {'name': 'Thai thang', 'symbol': 'thang'},
      ],
      'Historical Units': [
        {'name': 'Biblical log', 'symbol': 'log'},
        {'name': 'Biblical cab', 'symbol': 'cab'},
        {'name': 'Biblical omer', 'symbol': 'omer'},
        {'name': 'Biblical hin', 'symbol': 'hin'},
        {'name': 'Biblical seah', 'symbol': 'seah'},
        {'name': 'Biblical bath', 'symbol': 'bath'},
        {'name': 'Biblical ephah', 'symbol': 'ephah'},
        {'name': 'Biblical kor', 'symbol': 'kor'},
        {'name': 'Egyptian hin', 'symbol': 'hin'},
        {'name': 'Egyptian hekat', 'symbol': 'hekat'},
        {'name': 'Greek kyathos', 'symbol': 'kyath'},
        {'name': 'Greek kotyle', 'symbol': 'kotyl'},
        {'name': 'Greek chous', 'symbol': 'chous'},
        {'name': 'Greek metretes', 'symbol': 'metr'},
        {'name': 'Roman cyathus', 'symbol': 'cyath'},
        {'name': 'Roman acetabulum', 'symbol': 'acet'},
        {'name': 'Roman hemina', 'symbol': 'hem'},
        {'name': 'Roman sextarius', 'symbol': 'sext'},
        {'name': 'Roman congius', 'symbol': 'cong'},
        {'name': 'Roman modius', 'symbol': 'mod'},
        {'name': 'Roman urna', 'symbol': 'urna'},
        {'name': 'Roman amphora', 'symbol': 'amph'},
        {'name': 'Roman culeus', 'symbol': 'cul'},
      ],
      'Other Units': [
        {'name': 'Metric cup', 'symbol': 'c'},
      ],
    },
    'Temperature': {
      'Standard Units': [
        {'name': 'Celsius', 'symbol': '°C'},
        {'name': 'Fahrenheit', 'symbol': '°F'},
        {'name': 'Kelvin', 'symbol': 'K'},
      ],
      'Imperial Units': [
        {'name': 'Rankine', 'symbol': '°R'},
      ],
      'Scientific & Engineering': [
        {'name': 'Electron volt', 'symbol': 'eV'},
        {'name': 'Planck temperature', 'symbol': 'TP'},
        {'name': 'Gas mark', 'symbol': 'GM'},
      ],
      'Historical Units': [
        {'name': 'Delisle', 'symbol': '°De'},
        {'name': 'Newton', 'symbol': '°N'},
        {'name': 'Réaumur', 'symbol': '°Re'},
        {'name': 'Rømer', 'symbol': '°Rø'},
      ],
    },
    'Speed': {
      'Standard Units': [
        {'name': 'Kilometer / Hour', 'symbol': 'km/h'},
        {'name': 'Mile / Hour', 'symbol': 'mph'},
        {'name': 'Knot', 'symbol': 'kn'},
      ],
      'Metric Units': [
        {'name': 'Millimeter / Hour', 'symbol': 'mm/h'},
        {'name': 'Millimeter / Minute', 'symbol': 'mm/min'},
        {'name': 'Millimeter / Second', 'symbol': 'mm/s'},
        {'name': 'Centimeter / Hour', 'symbol': 'cm/h'},
        {'name': 'Centimeter / Minute', 'symbol': 'cm/min'},
        {'name': 'Centimeter / Second', 'symbol': 'cm/s'},
        {'name': 'Meter / Hour', 'symbol': 'm/h'},
        {'name': 'Meter / Minute', 'symbol': 'm/min'},
        {'name': 'Meter / Second', 'symbol': 'm/s'},
        {'name': 'Kilometer / Minute', 'symbol': 'km/min'},
        {'name': 'Kilometer / Second', 'symbol': 'km/s'},
      ],
      'Imperial Units': [
        {'name': 'Inch / Hour', 'symbol': 'in/h'},
        {'name': 'Inch / Minute', 'symbol': 'in/min'},
        {'name': 'Inch / Second', 'symbol': 'in/s'},
        {'name': 'Foot / Hour', 'symbol': 'ft/h'},
        {'name': 'Foot / Minute', 'symbol': 'ft/min'},
        {'name': 'Foot / Second', 'symbol': 'ft/s'},
        {'name': 'Yard / Hour', 'symbol': 'yd/h'},
        {'name': 'Yard / Minute', 'symbol': 'yd/min'},
        {'name': 'Yard / Second', 'symbol': 'yd/s'},
        {'name': 'Mile / Minute', 'symbol': 'mi/min'},
        {'name': 'Mile / Second', 'symbol': 'mi/s'},
      ],
      'Scientific': [
        {'name': 'Speed of sound', 'symbol': 'mach'},
        {'name': 'Speed of light', 'symbol': 'c'},
      ],
      'Historical': [
        {'name': 'Greek stadion / Hour', 'symbol': 'std/h'},
        {'name': 'Roman mile / Hour', 'symbol': 'rmi/h'},
      ],
    },
    'Pressure': {
      'Standard Units': [
        {'name': 'Bar', 'symbol': 'bar'},
        {'name': 'Millibar', 'symbol': 'mbar'},
      ],
      'Metric Units': [
        {'name': 'Pascal', 'symbol': 'Pa'},
        {'name': 'Hectopascal', 'symbol': 'hPa'},
        {'name': 'Kilopascal', 'symbol': 'kPa'},
        {'name': 'Megapascal', 'symbol': 'MPa'},
        {'name': 'Gigapascal', 'symbol': 'GPa'},
        {'name': 'Millimeter of water', 'symbol': 'mmH₂O'},
        {'name': 'Millimeter of mercury', 'symbol': 'mmHg'},
        {'name': 'Kilogram / Centimeter²', 'symbol': 'kg/cm²'},
      ],
      'Imperial Units': [
        {'name': 'Pound / Inch² (PSI)', 'symbol': 'psi'},
        {'name': 'Pound / Foot²', 'symbol': 'psf'},
        {'name': 'Inch of water', 'symbol': 'inH₂O'},
        {'name': 'Inch of mercury', 'symbol': 'inHg'},
        {'name': 'Kilopound / Inch²', 'symbol': 'ksi'},
      ],
      'Scientific & Engineering': [
        {'name': 'Torr', 'symbol': 'Torr'},
        {'name': 'Technical atmosphere', 'symbol': 'at'},
        {'name': 'Short ton / Inch²', 'symbol': 'tsi'},
        {'name': 'Short ton / Foot²', 'symbol': 'tsf'},
        {'name': 'Long ton / Inch²', 'symbol': 'lt/in²'},
        {'name': 'Long ton / Foot²', 'symbol': 'lt/ft²'},
      ],
      'Other & Historical': [
        {'name': 'Atmosphere', 'symbol': 'atm'},
        {'name': 'Foot of sea water', 'symbol': 'fsw'},
        {'name': 'Meter of sea water', 'symbol': 'msw'},
        {'name': 'Barye', 'symbol': 'Ba'},
        {'name': 'Pieze', 'symbol': 'pz'},
      ],
    },
    'Energy': {
      'Standard Units': [
        {'name': 'Joule', 'symbol': 'J'},
        {'name': 'Kilojoule', 'symbol': 'kJ'}, //[cite: 12]
        {'name': 'Calorie', 'symbol': 'cal'}, //[cite: 12]
        {'name': 'Kilocalorie', 'symbol': 'kcal'}, //[cite: 12]
      ],
      'Metric Units': [
        {'name': 'Megajoule', 'symbol': 'MJ'}, //[cite: 12]
        {'name': 'Gigajoule', 'symbol': 'GJ'}, //[cite: 12]
        {'name': 'Watt hour', 'symbol': 'Wh'}, //[cite: 12]
        {'name': 'Kilowatt hour', 'symbol': 'kWh'},
        {'name': 'Megawatt hour', 'symbol': 'MWh'}, //[cite: 12]
        {'name': 'Gigawatt hour', 'symbol': 'GWh'}, //[cite: 12]
      ],
      'Imperial Units': [
        {'name': 'Inch pound', 'symbol': 'in·lb'}, //[cite: 11]
        {'name': 'Foot pound', 'symbol': 'ft·lb'}, //[cite: 11]
        {'name': 'Therm', 'symbol': 'thm'}, //[cite: 11]
      ],
      'Scientific': [
        {'name': 'Erg', 'symbol': 'erg'}, //[cite: 11]
        {'name': 'Rydberg', 'symbol': 'Ry'}, //[cite: 11]
        {'name': 'Hartree', 'symbol': 'Ha'}, //[cite: 11]
        {'name': 'Electronvolt', 'symbol': 'eV'}, //[cite: 11]
      ],
      'Engineering': [
        {'name': 'Metric horsepower hour', 'symbol': 'PS·h'}, //[cite: 10, 11]
        {'name': 'Mechanical horsepower hour', 'symbol': 'hp·h'}, //[cite: 10]
      ],
      'Military': [
        {'name': 'Ton of TNT', 'symbol': 'tTNT'}, //[cite: 10]
        {'name': 'Kiloton of TNT', 'symbol': 'kTNT'}, //[cite: 10]
        {'name': 'Megaton of TNT', 'symbol': 'MTNT'}, //[cite: 10]
      ],
      'Other': [
        {'name': 'Barrel of oil equivalent', 'symbol': 'boe'}, //[cite: 10]
        {'name': 'Ton of coal equivalent', 'symbol': 'tce'}, //[cite: 10]
        {'name': 'Ton of oil equivalent', 'symbol': 'toe'}, //[cite: 10]
      ],
    },
    'Power': {
      'Standard Units': [
        {'name': 'Watt', 'symbol': 'W'},
        {'name': 'Kilowatt', 'symbol': 'kW'},
        {'name': 'Horsepower', 'symbol': 'hp'},
      ],
      'Metric Units': [
        {'name': 'Picowatt', 'symbol': 'pW'}, //[cite: 15]
        {'name': 'Nanowatt', 'symbol': 'nW'}, //[cite: 15]
        {'name': 'Microwatt', 'symbol': 'μW'}, //[cite: 15]
        {'name': 'Milliwatt', 'symbol': 'mW'}, //[cite: 15]
        {'name': 'Megawatt', 'symbol': 'MW'}, //[cite: 15]
        {'name': 'Gigawatt', 'symbol': 'GW'}, //[cite: 15]
      ],
      'Imperial Units': [
        {'name': 'Foot-pound / Minute', 'symbol': 'flb/m'}, //[cite: 15]
        {'name': 'Foot-pound / Second', 'symbol': 'flb/s'}, //[cite: 15]
        {'name': 'Btu / Hour', 'symbol': 'Btu/h'}, //[cite: 14]
        {'name': 'Btu / Minute', 'symbol': 'Btu/m'}, //[cite: 14]
        {'name': 'Btu / Second', 'symbol': 'Btu/s'}, //[cite: 14]
      ],
      'Scientific': [
        {'name': 'Erg / Second', 'symbol': 'erg/s'}, //[cite: 13, 14]
        {'name': 'Solar luminosity', 'symbol': 'L☉'}, //[cite: 13, 14]
      ],
      'Engineering': [
        {'name': 'Metric horsepower', 'symbol': 'PS'}, //[cite: 13, 14]
        {'name': 'Electrical horsepower', 'symbol': 'ehp'}, //[cite: 13, 14]
        {'name': 'Boiler horsepower', 'symbol': 'bhp'}, //[cite: 13, 14]
      ],
      'Historical & Other': [
        {'name': 'Poncelet', 'symbol': 'p'}, //[cite: 13]
        {'name': 'Kilocalorie / Hour', 'symbol': 'kcl/h'}, //[cite: 13]
        {'name': 'Calorie / Second', 'symbol': 'cal/s'}, //[cite: 13]
      ],
    },
    'Data': {
      'Base Units': [
        {'name': 'Bit', 'symbol': 'b'}, //[cite: 12]
        {'name': 'Nibble', 'symbol': 'n'}, //[cite: 12]
        {'name': 'Byte', 'symbol': 'B'}, //[cite: 11, 12]
      ],
      'Decimal Bytes (Multiples of 1000)': [
        {'name': 'Kilobyte', 'symbol': 'KB'}, //[cite: 11]
        {'name': 'Megabyte', 'symbol': 'MB'},
        {'name': 'Gigabyte', 'symbol': 'GB'},
        {'name': 'Terabyte', 'symbol': 'TB'},
        {'name': 'Petabyte', 'symbol': 'PB'}, //[cite: 11]
        {'name': 'Exabyte', 'symbol': 'EB'}, //[cite: 11]
      ],
      'Decimal Bits (Multiples of 1000)': [
        {'name': 'Kilobit', 'symbol': 'Kb'}, //[cite: 12]
        {'name': 'Megabit', 'symbol': 'Mb'}, //[cite: 12]
        {'name': 'Gigabit', 'symbol': 'Gb'}, //[cite: 12]
        {'name': 'Terabit', 'symbol': 'Tb'}, //[cite: 12]
        {'name': 'Petabit', 'symbol': 'Pb'}, //[cite: 12]
        {'name': 'Exabit', 'symbol': 'Eb'}, //[cite: 12]
      ],
      'Binary Bytes (Multiples of 1024)': [
        {'name': 'Kibibyte', 'symbol': 'KiB'}, //[cite: 10]
        {'name': 'Mebibyte', 'symbol': 'MiB'}, //[cite: 10]
        {'name': 'Gibibyte', 'symbol': 'GiB'}, //[cite: 10]
        {'name': 'Tebibyte', 'symbol': 'TiB'}, //[cite: 10]
        {'name': 'Pebibyte', 'symbol': 'PiB'}, //[cite: 10]
        {'name': 'Exbibyte', 'symbol': 'EiB'}, //[cite: 10]
      ],
      'Binary Bits (Multiples of 1024)': [
        {'name': 'Kibibit', 'symbol': 'Kib'}, //[cite: 11]
        {'name': 'Mebibit', 'symbol': 'Mib'}, //[cite: 11]
        {'name': 'Gibibit', 'symbol': 'Gib'}, //[cite: 11]
        {'name': 'Tebibit', 'symbol': 'Tib'}, //[cite: 10, 11]
        {'name': 'Pebibit', 'symbol': 'Pib'}, //[cite: 10, 11]
        {'name': 'Exbibit', 'symbol': 'Eib'}, //[cite: 10]
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