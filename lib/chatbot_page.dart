import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'backend_url.dart';
import 'location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PollutionVIZ',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const ChatbotPage(
        onToggleTheme: null,
        isDarkMode: false,
        location: AppLocation.fallback(),
      ),
    );
  }
}

class ChatbotPage extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;
  final AppLocation location;
  const ChatbotPage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
    required this.location,
  });

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<String> _tabs = [
    "Help",
    "Compare Locations",
    "Health Risks",
    "Policy Tips",
    "Fun Facts",
    "Myth Buster",
  ];
  int _selectedTab = 0;
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;
  String _response =
      "Hello! I'm Clarity, your pollution awareness assistant. How can I help you today?";

  /// Live conditions for the user's current location (city + pollutant values).
  /// Returns null if the backend call fails.
  Future<({String city, Map<String, dynamic> pollution})?> _currentConditions() async {
    final data = await fetchDashboardData(
      lat: widget.location.lat,
      lon: widget.location.lon,
    );
    final pollution = data?['pollution'];
    if (data == null || pollution is! Map<String, dynamic>) return null;
    final city = data['location']?['city'] ?? widget.location.label ?? 'your location';
    return (city: city.toString(), pollution: pollution);
  }

  double _num(Map<String, dynamic> p, String key) =>
      (p[key] as num?)?.toDouble() ?? 0.0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = index;
      switch (index) {
        case 0:
          _response = "Fetching Clarity help info...";
          _fetchHelpInfo();
          break;
        case 1:
          _response =
              "Compare Locations: Enter two locations (e.g., 'Delhi vs Mumbai' or 'Pune, Bangalore') to compare health impacts.";
          break;
        case 2:
          _response =
              "Health Risks: Enter a location or pollutant level to get risk breakdown for children, adults, and the elderly.";
          break;
        case 3:
          _response =
              "Policy Tips: Enter a city or goal (e.g., 'Reduce vehicle emissions in Delhi') to get actionable policy recommendations.";
          break;
        case 4:
          _response =
              "Fun Facts & Explanations: Enter any pollutant (e.g., 'PM2.5', 'NO2', 'Ozone', 'CO') to learn about its causes and effects.";
          break;
        case 5:
          _response =
              "Myth Buster: Enter any air pollution claim to test whether it's True or False!";
          break;
        default:
          _response = "You selected ${_tabs[index]}. What would you like to know?";
      }
    });
  }

  Future<void> _fetchHelpInfo() async {
    setState(() => _isSearching = true);
    try {
      final helpText = await fetchClarityHelp();
      setState(() {
        _response = helpText ??
            "Clarity explains pollution data and health risks, suggests actions, predicts policy impacts, and creates scenarios.";
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _response = "Error loading help info: $e";
        _isSearching = false;
      });
    }
  }

  Future<void> _onSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty && _selectedTab != 0) return;

    setState(() {
      _isSearching = true;
      _response = "Processing...";
    });

    try {
      String formattedResponse = "";

      switch (_selectedTab) {
        case 0: // Help
          final helpText = await fetchClarityHelp();
          formattedResponse = helpText ?? "No help information available.";
          break;

        case 1: // Compare Locations
          List<String> places = query.split(RegExp(r'\s+(?:vs|and|,)\s+|\s*,\s*', caseSensitive: false));
          String loc1 = places.isNotEmpty ? places[0] : "Location 1";
          String loc2 = places.length > 1 ? places[1] : "Location 2";
          final result = await compareLocations(
            location1: loc1,
            location2: loc2,
          );
          if (result is Map && result.containsKey('error')) {
            formattedResponse = result['error'].toString();
          } else if (result is Map && result.containsKey('comparison')) {
            formattedResponse = result['comparison'].toString();
          } else {
            formattedResponse = json.encode(result);
          }
          break;

        case 2: // Health Risks
          final cond = await _currentConditions();
          if (cond == null) {
            formattedResponse = "Couldn't load current air quality for your location. Please try again.";
            break;
          }
          final p = cond.pollution;
          final result = await fetchHealthRisks(
            pm25: _num(p, 'pm25'),
            pm10: _num(p, 'pm10'),
            no2: _num(p, 'no2'),
            co: _num(p, 'co'),
            o3: _num(p, 'o3'),
          );
          if (result is Map) {
            final children = result['children'] ?? 'N/A';
            final adults = result['adults'] ?? 'N/A';
            final elderly = result['elderly'] ?? 'N/A';
            formattedResponse = "👶 Children:\n$children\n\n🧑 Adults:\n$adults\n\n👵 Elderly:\n$elderly";
          } else {
            formattedResponse = json.encode(result);
          }
          break;

        case 3: // Policy Tips
          if (query.toLowerCase().contains("plan") || query.toLowerCase().contains("reduce") || query.toLowerCase().contains("goal")) {
            final cond = await _currentConditions();
            final result = await reducePollutionPlan(
              goal: query,
              location: cond?.city ?? widget.location.label ?? 'my location',
            );
            if (result is Map && result.containsKey('plan')) {
              final plan = (result['plan'] as List).join('\n• ');
              formattedResponse = "🎯 Goal: ${result['goal']}\n📍 Location: ${result['location']}\n\nPlan:\n• $plan";
            } else {
              formattedResponse = json.encode(result);
            }
          } else {
            final cond = await _currentConditions();
            if (cond == null) {
              formattedResponse = "Couldn't load current air quality for your location. Please try again.";
              break;
            }
            final p = cond.pollution;
            final result = await suggestPolicies(
              location: cond.city,
              aqi: (p['aqi'] as num?)?.round() ?? 0,
              pm25: _num(p, 'pm25'),
              pm10: _num(p, 'pm10'),
              no2: _num(p, 'no2'),
              co: _num(p, 'co'),
              o3: _num(p, 'o3'),
            );

            if (result is List) {
              formattedResponse = "Suggested Policies for ${cond.city}:\n\n" +
                  result.asMap().entries.map((e) => "${e.key + 1}. ${e.value}").join("\n\n");
            } else {
              formattedResponse = json.encode(result);
            }
          }
          break;

        case 4: // Fun Facts / Explain
          final result = await fetchExplainPollutant(query.isNotEmpty ? query : "PM2.5");
          if (result is Map) {
            final obj = result['object'] ?? '';
            final causes = result['causes'] is List ? (result['causes'] as List).join('\n• ') : '';
            final effects = result['effects'] is List ? (result['effects'] as List).join('\n• ') : '';
            formattedResponse = "📘 $obj\n\n🏭 Causes:\n• $causes\n\n⚠️ Effects:\n• $effects";
          } else {
            formattedResponse = json.encode(result);
          }
          break;

        case 5: // Myth Buster
          final result = await fetchMythBuster(query);
          if (result is Map) {
            final verdict = result['verdict'] ?? 'Unknown';
            final explanation = result['explanation'] ?? '';
            formattedResponse = "Verdict: ${verdict.toUpperCase() == 'TRUE' ? '✅ TRUE' : '❌ FALSE'}\n\n$explanation";
          } else {
            formattedResponse = json.encode(result);
          }
          break;

        default:
          final helpText = await fetchClarityHelp();
          formattedResponse = helpText ?? "No information available.";
      }

      setState(() {
        _response = formattedResponse;
        _isSearching = false;
        _controller.clear();
      });
    } catch (e) {
      setState(() {
        _response = "Error: $e";
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              const FlutterLogo(size: 28),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'PollutionVIZ',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _ChatbotBody(
        tabs: _tabs,
        selectedTab: _selectedTab,
        onTabSelected: _onTabSelected,
        controller: _controller,
        onSearch: _onSearch,
        isSearching: _isSearching,
        response: _response,
        isDark: isDark,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: isDark ? Colors.white : Colors.green,
        unselectedItemColor: isDark ? const Color(0xFFB0B3B8) : Colors.black54,
        backgroundColor: isDark ? const Color(0xFF23242B) : Colors.white,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: 'Scenarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontFamily: 'Montserrat'),
      ),
    );
  }
}

class _ChatbotBody extends StatelessWidget {
  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final TextEditingController controller;
  final VoidCallback onSearch;
  final bool isSearching;
  final String response;
  final bool isDark;

  const _ChatbotBody({
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
    required this.controller,
    required this.onSearch,
    required this.isSearching,
    required this.response,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2DE3A7)
                        : Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: isDark ? Colors.white : Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Clarity",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your pollution awareness assistant",
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 18),
                // Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      tabs.length,
                      (i) => GestureDetector(
                        onTap: () => onTabSelected(i),
                        child: _ChatTab(
                          label: tabs[i],
                          selected: i == selectedTab,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  width: 80,
                  margin: const EdgeInsets.only(left: 8),
                  color: isDark ? Colors.greenAccent : Colors.green,
                ),
                const SizedBox(height: 18),
                // Chat bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth < 340
                        ? constraints.maxWidth - 32
                        : 340,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF23242B) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: isSearching
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: isDark
                                    ? Colors.greenAccent
                                    : Colors.green,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Searching...",
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          response,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                ),
                const SizedBox(height: 18),
                // Input
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth < 340
                          ? constraints.maxWidth - 32
                          : 340,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF23242B) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              minLines: 1,
                              maxLines: 4,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Ask me about pollution...",
                                hintStyle: GoogleFonts.montserrat(
                                  color: isDark ? Colors.white54 : Colors.grey,
                                ),
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              style: GoogleFonts.montserrat(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              onSubmitted: (_) => onSearch(),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2DE3A7)
                                  : Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                              ),
                              onPressed: onSearch,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatTab extends StatelessWidget {
  final String label;
  final bool selected;
  const _ChatTab({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? (isDark ? const Color(0xFF2DE3A7) : Colors.green)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          color: selected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
