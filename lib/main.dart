import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_json_view/flutter_json_view.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(ApiTesterApp());
}

class ApiTesterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Response Lab',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.tealAccent,
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Colors.tealAccent),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: ApiHomePage(),
    );
  }
}

class ApiHomePage extends StatefulWidget {
  @override
  _ApiHomePageState createState() => _ApiHomePageState();
}

class _ApiHomePageState extends State<ApiHomePage> {
  String _selectedMethod = 'GET';
  http.Response? _response;
  final _methods = ['GET', 'POST', 'PUT', 'DELETE'];

  final _urlController = TextEditingController();
  final _bodyController = TextEditingController();
  final _paramKeyController = TextEditingController();
  final _paramValueController = TextEditingController();
  final List<Map<String, String>> _queryParams = [];

  // Variables for ads
  late BannerAd _bannerAd;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    try {
      final url = Uri.parse(_buildUrlWithParams(_urlController.text.trim()));
      http.Response response;

      switch (_selectedMethod) {
        case 'POST':
          response = await http.post(url, body: _bodyController.text);
          break;
        case 'PUT':
          response = await http.put(url, body: _bodyController.text);
          break;
        case 'DELETE':
          response = await http.delete(url);
          break;
        default:
          response = await http.get(url);
      }

      setState(() => _response = response);

      // Show interstitial ad after sending the request
      _interstitialAd?.show();
      _createInterstitialAd(); // Load a new interstitial ad for next time
    } catch (e) {
      setState(() => _response = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _buildUrlWithParams(String baseUrl) {
    if (_queryParams.isEmpty) return baseUrl;

    final uri = Uri.parse(baseUrl);
    final queryParams = Map.fromEntries(
      _queryParams.map((param) => MapEntry(param['key']!, param['value']!)),
    );
    final newUri = uri.replace(queryParameters: queryParams);
    return newUri.toString();
  }

  void _addParameter() {
    if (_paramKeyController.text.isNotEmpty &&
        _paramValueController.text.isNotEmpty) {
      setState(() {
        _queryParams.add({
          'key': _paramKeyController.text,
          'value': _paramValueController.text,
        });
      });
      _paramKeyController.clear();
      _paramValueController.clear();
    }
  }

  void _copyResponse() {
    if (_response != null) {
      Clipboard.setData(ClipboardData(text: _response!.body));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Response copied to clipboard')),
      );
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-5500303894286506/3537722735',
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-5500303894286506/6592971343',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Color(0xFF1E1E1E)),
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 200,
              color: Colors.tealAccent,
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 150),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedTextField(
                    controller: _urlController,
                    label: 'Enter API URL',
                    icon: Icons.link,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: _buildAnimatedTextField(
                          controller: _paramKeyController,
                          label: 'Param Key',
                          icon: Icons.vpn_key,
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: _buildAnimatedTextField(
                          controller: _paramValueController,
                          label: 'Param Value',
                          icon: Icons.code,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.tealAccent),
                        onPressed: _addParameter,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildQueryParamList(),
                  _buildMethodDropdown(),
                  if (_selectedMethod == 'POST' || _selectedMethod == 'PUT')
                    _buildAnimatedTextField(
                      controller: _bodyController,
                      label: 'Request Body (JSON)',
                      icon: Icons.description,
                      maxLines: 5,
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _sendRequest,
                    child: Text('Send Request', style: TextStyle(fontSize: 18)),
                  ),
                  SizedBox(height: 20),
                  if (_response != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResponseCard(_response!),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _copyResponse,
                          child: Text('Copy Response'),
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  // Banner Ad
                  Container(
                    alignment: Alignment.center,
                    child: AdWidget(ad: _bannerAd),
                    width: _bannerAd.size.width.toDouble(),
                    height: _bannerAd.size.height.toDouble(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.tealAccent),
        labelText: label,
      ),
    );
  }

  Widget _buildQueryParamList() {
    if (_queryParams.isEmpty) return SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _queryParams.length,
      itemBuilder: (context, index) {
        final param = _queryParams[index];
        return ListTile(
          title: Text('${param['key']}: ${param['value']}'),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => setState(() => _queryParams.removeAt(index)),
          ),
        );
      },
    );
  }

  Widget _buildMethodDropdown() {
    return DropdownButton<String>(
      value: _selectedMethod,
      isExpanded: true,
      items: _methods.map((method) {
        return DropdownMenuItem(value: method, child: Text(method));
      }).toList(),
      onChanged: (value) => setState(() => _selectedMethod = value!),
    );
  }

  Widget _buildResponseCard(http.Response response) {
    final statusColor = response.statusCode < 300 ? Colors.green : Colors.red;

    return Card(
      color: Colors.grey[850],
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Status: ${response.statusCode}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 18,
                  ),
                ),
                Spacer(),
                Text(response.reasonPhrase ?? '',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 10),
            ExpansionTile(
              title: Text('Headers',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: response.headers.entries.map((entry) {
                return ListTile(title: Text('${entry.key}: ${entry.value}'));
              }).toList(),
            ),
            SizedBox(height: 10),
            ExpansionTile(
              title:
                  Text('Body', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [_buildJsonView(response.body)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonView(String responseBody) {
    try {
      final json = jsonDecode(responseBody);
      return JsonView.map(json);
    } catch (e) {
      return Text(responseBody);
    }
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 100);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 80);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 160);
    var secondEndPoint = Offset(size.width, size.height - 100);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
