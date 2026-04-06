import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';

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

  /// Read all rows from a sheet (skipping header row)
  Future<List<List<Object?>>> getRows(String sheetName) async {
    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      '$sheetName!A2:G',
    );
    return response.values ?? [];
  }

  /// Append a row to the sheet
  Future<void> appendRow(String sheetName, List<Object> row) async {
    final valueRange = sheets.ValueRange(values: [row]);
    await sheetsApi.spreadsheets.values.append(
      valueRange,
      spreadsheetId,
      '$sheetName!A:G',
      valueInputOption: 'RAW',
    );
  }

  /// Update a specific row (1-indexed, row 1 is header)
  Future<void> updateRow(String sheetName, int rowIndex, List<Object> row) async {
    final valueRange = sheets.ValueRange(values: [row]);
    await sheetsApi.spreadsheets.values.update(
      valueRange,
      spreadsheetId,
      '$sheetName!A$rowIndex:G$rowIndex',
      valueInputOption: 'RAW',
    );
  }

  /// Delete a row by clearing it (Sheets API doesn't support row deletion directly)
  Future<void> clearRow(String sheetName, int rowIndex) async {
    await sheetsApi.spreadsheets.values.clear(
      sheets.ClearValuesRequest(),
      spreadsheetId,
      '$sheetName!A$rowIndex:G$rowIndex',
    );
  }

  /// Ensure headers exist on first row
  Future<void> ensureHeaders(String sheetName, List<String> headers) async {
    final response = await sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      '$sheetName!A1:G1',
    );
    if (response.values == null || response.values!.isEmpty) {
      final valueRange = sheets.ValueRange(values: [headers]);
      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        '$sheetName!A1:G1',
        valueInputOption: 'RAW',
      );
    }
  }

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