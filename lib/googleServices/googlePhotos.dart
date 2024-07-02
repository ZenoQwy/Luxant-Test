import 'package:googleapis/drive/v3.dart' as drive;
import 'package:url_launcher/url_launcher.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

// Documentation : https://developers.google.com/drive/api/guides/about-sdk?hl=fr

class GoogleDriveApiService {
  // Liste des scopes d'accès requis pour l'application, dans ce cas l'accès à Google Drive.
  final List<String> _scopes = [drive.DriveApi.driveFileScope];

  // Méthode pour charger les informations d'identification à partir du fichier credentials.json dans les assets.
  Future<Map<String, dynamic>> _loadCredentials() async {
    // 1 | Décode le contenu JSON du fichier en un objet Dart (Map).
    final jsonStr = await rootBundle.loadString('assets/credentials.json');

    // 2 | Décode le contenu JSON du fichier en un objet Dart (Map).
    final credentials = json.decode(jsonStr);

    // 3 | Retourne la partie 'installed' du fichier JSON qui contient le client_id et le client_secret.
    return credentials['installed'];
  }

  // Méthode permettant l'obtention d'un client HTTP authentifié.
  Future<AuthClient> getHttpClient() async {
    // 1 | Charge les informations d'identification.
    final credentials = await _loadCredentials();

    // 2 | Création d'un ClientId à partir des informations d'identification.
    final clientId = ClientId(credentials['client_id'], credentials['client_secret']);

    // 3 | Obtention d'un client HTTP authentifié via OAuth en utilisant le consentement de l'utilisateur.
    AuthClient authClient = await clientViaUserConsent(clientId, _scopes, _userPrompt);
    return authClient;
  }

  // Méthode pour uploader un fichier vers Google Drive.
  Future<void> upload(File file) async {
    // 1 | Obtention d'un client HTTP authentifié.
    AuthClient client = await getHttpClient();

    // 2 | Crée une instance de l'API Google Drive.
    var driveApi = drive.DriveApi(client);

    // 3 | Crée un fichier à uploader sur Google Drive.
    var media = drive.Media(file.openRead(), file.lengthSync());
    var driveFile = drive.File();
    driveFile.name = file.path.split('/').last;

    // 4 | Upload du fichier sur Google Drive.
    var result = await driveApi.files.create(driveFile, uploadMedia: media);

  }

  // Méthode pour lancer l'URL de consentement utilisateur dans le navigateur.
  void _userPrompt(String url) {
    launch(url);
  }
}
