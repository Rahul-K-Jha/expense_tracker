import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/expense/data/datasources/google_sheets_service.dart';

class AuthService {
  static const _keySignedIn = 'is_signed_in';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      sheets.SheetsApi.spreadsheetsScope,
    ],
  );

  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName;
  String? get userPhotoUrl => _currentUser?.photoUrl;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keySignedIn, true);
      }
      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySignedIn, false);
  }

  Future<bool> trySilentSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    final wasPreviouslySignedIn = prefs.getBool(_keySignedIn) ?? false;
    if (!wasPreviouslySignedIn) return false;

    try {
      _currentUser = await _googleSignIn.signInSilently();
      return _currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Create a GoogleSheetsService authenticated with the current user's credentials.
  Future<GoogleSheetsService?> createSheetsService(String spreadsheetId) async {
    if (_currentUser == null) return null;

    final headers = await _currentUser!.authHeaders;
    final client = _AuthenticatedClient(headers);
    final sheetsApi = sheets.SheetsApi(client);

    return GoogleSheetsService(
      spreadsheetId: spreadsheetId,
      sheetsApi: sheetsApi,
    );
  }
}

class _AuthenticatedClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}
