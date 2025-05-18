import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (context) => const SheetSelectorPage());
        }
        // Always show SplashScreen for any other or unknown route
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      },
    );
  }
}

class SheetSelectorPage extends StatefulWidget {
  const SheetSelectorPage({super.key});

  @override
  State<SheetSelectorPage> createState() => _SheetSelectorPageState();
}

class _SheetSelectorPageState extends State<SheetSelectorPage> {
  String? selectedSheet;
  List<String> sheetNames = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // _loadSheetNames();
  }

  Future<void> _loadSheetNames() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Replace with your spreadsheet ID
      const spreadsheetId = 'YOUR_SPREADSHEET_ID';
      final client = await _getAuthenticatedClient();
      final sheetsApi = sheets.SheetsApi(client);
      
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      final names = spreadsheet.sheets?.map((sheet) => sheet.properties?.title ?? '').toList() ?? [];
      
      setState(() {
        sheetNames = names;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading sheets: $e')),
      );
    }
  }

  Future<http.Client> _getAuthenticatedClient() async {
    // TODO: Replace with your credentials
    const credentials = {
      "installed": {
        "client_id": "YOUR_CLIENT_ID",
        "project_id": "YOUR_PROJECT_ID",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_secret": "YOUR_CLIENT_SECRET",
        "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob", "http://localhost"]
      }
    };

    final authCredentials = ServiceAccountCredentials.fromJson(credentials);
    return await clientViaServiceAccount(
      authCredentials,
      [sheets.SheetsApi.spreadsheetsReadonlyScope],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Sheet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Sheets:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButton<String>(
                value: selectedSheet,
                hint: const Text('Select a sheet'),
                isExpanded: true,
                items: sheetNames.map((String sheetName) {
                  return DropdownMenuItem<String>(
                    value: sheetName,
                    child: Text(sheetName),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSheet = newValue;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
} 