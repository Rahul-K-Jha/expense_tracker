import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences.dart';

class GoogleSheetsService {
  static const _scopes = [SheetsApi.spreadsheetsReadonlyScope];
  static const _credentials = {
    // You'll need to replace these with your own credentials
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

  Future<List<String>> getSheetNames(String spreadsheetId) async {
    try {
      final client = await _getAuthenticatedClient();
      final sheetsApi = SheetsApi(client);
      
      final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
      return spreadsheet.sheets?.map((sheet) => sheet.properties?.title ?? '').toList() ?? [];
    } catch (e) {
      print('Error fetching sheet names: $e');
      return [];
    }
  }

  Future<http.Client> _getAuthenticatedClient() async {
    final credentials = ServiceAccountCredentials.fromJson(_credentials);
    return await clientViaServiceAccount(credentials, _scopes);
  }
} 