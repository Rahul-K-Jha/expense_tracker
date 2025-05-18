import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class GoogleSheetsService {
  final String spreadsheetId;
  final sheets.SheetsApi sheetsApi;

  GoogleSheetsService({required this.spreadsheetId, required this.sheetsApi});

  // Example: Fetch sheet names
  Future<List<String>> getSheetNames() async {
    final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
    return spreadsheet.sheets
            ?.map((sheet) => sheet.properties?.title ?? '')
            .where((title) => title.isNotEmpty)
            .toList() ??
        [];
  }

  // Add more methods for reading/writing expenses as needed

  // Example static method for authentication (Service Account)
  static Future<GoogleSheetsService> createWithServiceAccount(
      String spreadsheetId, Map<String, dynamic> credentialsJson) async {
    final authCredentials = ServiceAccountCredentials.fromJson(credentialsJson);
    final client = await clientViaServiceAccount(
      authCredentials,
      [sheets.SheetsApi.spreadsheetsScope],
    );
    final sheetsApi = sheets.SheetsApi(client);
    return GoogleSheetsService(
      spreadsheetId: spreadsheetId,
      sheetsApi: sheetsApi,
    );
  }
} 