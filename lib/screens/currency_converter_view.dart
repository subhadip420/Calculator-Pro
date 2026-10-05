import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../app_colors.dart';
import '../custom_action_button.dart';
import '../custom_converter_keyboard.dart';
import '../custom_conversion_card.dart';
import '../custom_toast.dart';
import 'package:calculator_pro/custom_unit_selector_sheet.dart';
import '../custom_top_bar.dart';

class CurrencyConverterView extends StatefulWidget {
  final VoidCallback onBack;

  const CurrencyConverterView({super.key, required this.onBack});

  @override
  State<CurrencyConverterView> createState() => _CurrencyConverterViewState();
}

class _CurrencyConverterViewState extends State<CurrencyConverterView> with SingleTickerProviderStateMixin {
  bool _isHapticsEnabled = true;
  String _buttonShape = 'rounded';
  bool isFromSelected = true;

  // Defaults
  String fromUnit = 'United States Dollar (USD)';
  String fromSymbol = '\$';
  String fromValue = '1';

  String toUnit = 'Indian Rupee (INR)';
  String toSymbol = '₹';
  String toValue = '83.50'; // Ye load hote hi automatically asli value se update ho jayega

  late TextEditingController _fromController;
  late TextEditingController _toController;

  late AnimationController _refreshController;
  bool _isRefreshing = false;

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  //final String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  final String _rewardedAdUnitId = 'ca-app-pub-5454466291921987/7034491178';

  final Map<String, double> currencyRates = {
    'usd': 1.0,
    'inr': 83.50,
    'eur': 0.92,
    'gbp': 0.79,
    'jpy': 151.20,
    'aud': 1.52,
    'cad': 1.36,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fromController = TextEditingController(text: fromValue);
    _toController = TextEditingController(text: toValue);

    _refreshController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _loadRewardedAd();

    // --- NAYA FIX: Pehle offline data load karo, fir Auto Refresh karo ---
    _loadOfflineRates().then((_) {
      _autoRefreshOnOpen();
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
      _buttonShape = prefs.getString('button_shape') ?? 'rounded';
    });
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  Future<void> _loadOfflineRates() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedRates = prefs.getString('saved_currency_rates');

    if (savedRates != null) {
      final Map<String, dynamic> decodedRates = jsonDecode(savedRates);
      setState(() {
        currencyRates.clear();
        decodedRates.forEach((key, value) {
          currencyRates[key.toLowerCase()] = (value as num).toDouble();
        });
        _calculateConversion(); // Saved rates ke hisaab se update
      });
    }
  }

  // --- NAYA FIX: Auto Refresh function (Bina Ad ke) ---
  Future<void> _autoRefreshOnOpen() async {
    bool hasInternet = await _checkInternet();
    if (!hasInternet) {
      if (mounted) showCustomToast(context, 'No internet connection');
      return;
    }

    setState(() => _isRefreshing = true);
    _refreshController.repeat();

    // Pehli baar bina kisi Rewarded Ad ke background me rates fetch karo
    await _fetchRatesFromFreeAPI();
  }

  // Manual Refresh Button Click (Ad ke sath)
  Future<void> _onRefresh() async {
    if (_isRefreshing) return;

    if (_isHapticsEnabled) HapticFeedback.lightImpact();

    bool hasInternet = await _checkInternet();
    if (!hasInternet) {
      if (mounted) showCustomToast(context, 'No internet connection');
      return;
    }

    setState(() => _isRefreshing = true);
    _refreshController.repeat();

    if (_isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          _fetchRatesFromFreeAPI();
        },
      );

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
          // Stop spinner if they close ad before reward
          setState(() => _isRefreshing = false);
          _refreshController.stop();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _fetchRatesFromFreeAPI();
        },
      );
    } else {
      _fetchRatesFromFreeAPI();
      _loadRewardedAd();
    }
  }

  Future<void> _fetchRatesFromFreeAPI() async {
    try {
      const String url = 'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, dynamic> apiRates = data['usd'];

        setState(() {
          currencyRates.clear();
          apiRates.forEach((key, value) {
            currencyRates[key.toString().toLowerCase()] = (value as num).toDouble();
          });

          // Ye call hote hi '83.50' hatkar exact live rate set ho jayega UI me!
          _calculateConversion();
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_currency_rates', jsonEncode(currencyRates));

        // NAYA: Toast message updated as requested
        if (mounted) showCustomToast(context, 'Values updated');
      } else {
        if (mounted) showCustomToast(context, 'Failed to fetch rates');
      }
    } catch (e) {
      if (mounted) showCustomToast(context, 'Something went wrong');
    } finally {
      _refreshController.stop();
      setState(() => _isRefreshing = false);
    }
  }

  String _extractCurrencyCode(String name) {
    RegExp regExp = RegExp(r'\(([A-Z]{3})\)');
    var match = regExp.firstMatch(name);
    if (match != null) {
      return match.group(1)!.toLowerCase();
    }
    return 'usd';
  }

  String _formatResult(double value) {
    if (value == 0) return '0';
    String res = value.toStringAsPrecision(8);
    if (res.contains('.')) {
      res = res.replaceAll(RegExp(r'0*$'), '');
      res = res.replaceAll(RegExp(r'\.$'), '');
    }
    return res;
  }

  void _calculateConversion() {
    String fromCode = _extractCurrencyCode(fromUnit);
    String toCode = _extractCurrencyCode(toUnit);

    double rateFrom = currencyRates[fromCode] ?? 1.0;
    double rateTo = currencyRates[toCode] ?? 1.0;

    if (isFromSelected) {
      double inputValue = double.tryParse(fromValue) ?? 0.0;
      double result = (inputValue / rateFrom) * rateTo;
      toValue = _formatResult(result);
      _toController.text = toValue;
    } else {
      double inputValue = double.tryParse(toValue) ?? 0.0;
      double result = (inputValue / rateTo) * rateFrom;
      fromValue = _formatResult(result);
      _fromController.text = fromValue;
    }
  }

  void _onKeyPress(String key) {
    setState(() {
      TextEditingController activeController = isFromSelected ? _fromController : _toController;

      int cursorPos = activeController.selection.baseOffset;
      if (cursorPos < 0) cursorPos = activeController.text.length;

      String currentText = activeController.text;

      if (key == '.' && currentText.contains('.')) return;

      String newText;
      if (currentText == '0' && key != '.') {
        newText = key;
        cursorPos = 0;
      } else {
        newText = currentText.substring(0, cursorPos) + key + currentText.substring(cursorPos);
      }

      activeController.text = newText;
      activeController.selection = TextSelection.collapsed(offset: cursorPos + key.length);

      if (isFromSelected) {
        fromValue = newText;
      } else {
        toValue = newText;
      }

      _calculateConversion();
    });
  }

  void _onBackspace() {
    setState(() {
      TextEditingController activeController = isFromSelected ? _fromController : _toController;
      int cursorPos = activeController.selection.baseOffset;

      if (cursorPos <= 0) return;

      String currentText = activeController.text;

      String newText = currentText.substring(0, cursorPos - 1) + currentText.substring(cursorPos);

      if (newText.isEmpty || newText == '-') {
        newText = '0';
      }

      activeController.text = newText;
      activeController.selection = TextSelection.collapsed(offset: newText == '0' ? 1 : cursorPos - 1);

      if (isFromSelected) {
        fromValue = newText;
      } else {
        toValue = newText;
      }

      _calculateConversion();
    });
  }

  void _onClear() {
    setState(() {
      fromValue = '0';
      toValue = '0';
      _fromController.text = '0';
      _toController.text = '0';

      _fromController.selection = const TextSelection.collapsed(offset: 1);
      _toController.selection = const TextSelection.collapsed(offset: 1);
    });
  }

  void _swapUnits() {
    if (_isHapticsEnabled) HapticFeedback.lightImpact();
    setState(() {
      String tempUnit = fromUnit;
      String tempSymbol = fromSymbol;

      fromUnit = toUnit;
      fromSymbol = toSymbol;

      toUnit = tempUnit;
      toSymbol = tempSymbol;

      _calculateConversion();
    });
  }

  void _showUnitPicker(bool isFrom) async {
    if (_isHapticsEnabled) HapticFeedback.selectionClick();

    final selectedUnit = await showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return const UnitSelectorSheet(category: 'Currency');
      },
    );

    if (selectedUnit != null) {
      setState(() {
        if (isFrom) {
          fromUnit = selectedUnit['name']!;
          fromSymbol = selectedUnit['symbol']!;
        } else {
          toUnit = selectedUnit['name']!;
          toSymbol = selectedUnit['symbol']!;
        }

        _calculateConversion();
      });
    }
  }

  String _getEquivalenceText() {
    String fromCode = _extractCurrencyCode(fromUnit);
    String toCode = _extractCurrencyCode(toUnit);

    double rateFrom = currencyRates[fromCode] ?? 1.0;
    double rateTo = currencyRates[toCode] ?? 1.0;

    if (isFromSelected) {
      double eqValue = rateTo / rateFrom;
      return '1 $fromCode = ${_formatResult(eqValue)} $toCode'.toUpperCase();
    } else {
      double eqValue = rateFrom / rateTo;
      return '1 $toCode = ${_formatResult(eqValue)} $fromCode'.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isShortScreen = screenHeight < 720;

    final double cardVerticalPadding = isShortScreen ? 4.0 : 10.0;
    final double cardGap = isShortScreen ? 12.0 : 16.0;
    final double swapBtnSize = isShortScreen ? 40.0 : 46.0;
    final double swapIconSize = isShortScreen ? 22.0 : 26.0;

    return Column(
      children: [
        CustomTopBar(
          toolId: 'currency',
          title: 'Currency',
          iconPath: 'assets/images/currency.png',
          onBack: widget.onBack,
          isHapticsEnabled: _isHapticsEnabled,
        ),

        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false, // Yeh line Expanded ko crash hone se rokegi
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: cardVerticalPadding),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConversionCard(
                                  isActive: isFromSelected,
                                  unitName: fromUnit,
                                  unitSymbol: fromSymbol,
                                  controller: _fromController,
                                  onTap: () {
                                    setState(() {
                                      isFromSelected = true;
                                    });
                                  },
                                  onUnitTap: () => _showUnitPicker(true),
                                ),

                                SizedBox(height: cardGap),

                                ConversionCard(
                                  isActive: !isFromSelected,
                                  unitName: toUnit,
                                  unitSymbol: toSymbol,
                                  controller: _toController,
                                  onTap: () {
                                    setState(() {
                                      isFromSelected = false;
                                    });
                                  },
                                  onUnitTap: () => _showUnitPicker(false),
                                ),
                              ],
                            ),

                            GestureDetector(
                              onTap: _swapUnits,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: swapBtnSize,
                                width: swapBtnSize,
                                decoration: BoxDecoration(
                                  color: AppColors.cyanColor(context),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.bgColor(context), width: isShortScreen ? 3 : 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cyanColor(context).withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.swap_vert_rounded,
                                  color: const Color(0xFF003640),
                                  size: swapIconSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: isShortScreen ? 2.0 : 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              key: ValueKey<String>(_getEquivalenceText()),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: isShortScreen ? 4.0 : 6.0),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceColor(context).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Text(
                                _getEquivalenceText(),
                                style: TextStyle(
                                  color: AppColors.cyanColor(context).withOpacity(0.9),
                                  fontSize: isShortScreen ? 13 : 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          Tooltip(
                            message: 'Refresh rates',
                            child: GestureDetector(
                              onTap: _onRefresh,
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceColor(context).withOpacity(0.4),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: RotationTransition(
                                  turns: _refreshController,
                                  child: Icon(
                                    Icons.refresh_rounded,
                                    color: _isRefreshing ? AppColors.cyanColor(context) : AppColors.textGrey(context),
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isShortScreen ? 4 : 8),

                    ConverterKeyboard(
                      buttonShape: _buttonShape,
                      isHapticsEnabled: _isHapticsEnabled,
                      onKeyPress: _onKeyPress,
                      onBackspace: _onBackspace,
                      onClear: _onClear,
                    ),

                    SizedBox(height: isShortScreen ? 4 : 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
