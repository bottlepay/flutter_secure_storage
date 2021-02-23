# flutter_secure_storage

A Flutter plugin to store data in secure storage:
* [Keychain](https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/01introduction/introduction.html#//apple_ref/doc/uid/TP30000897-CH203-TP1) is used for iOS 
* AES encryption is used for Android. AES secret key is encrypted with RSA and RSA key is stored in [KeyStore](https://developer.android.com/training/articles/keystore.html)

*Note* KeyStore was introduced in Android 4.3 (API level 18). The plugin wouldn't work for earlier versions.

## Getting Started
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create storage
final storage = new FlutterSecureStorage();

// Read value 
String value = await storage.read(key: key);

// Read all values
Map<String, String> allValues = await storage.readAll();

// Delete value 
await storage.delete(key: key);

// Delete all 
await storage.deleteAll();

// Write value 
await storage.write(key: key, value: value);

```

### Configure Android version 
In `[project]/android/app/build.gradle` set `minSdkVersion` to >= 18.
```
android {
    ...
    
    defaultConfig {
        ...
        minSdkVersion 18
        ...
    }

}
```
*Note* By default Android backups data on Google Drive. It can cause exception java.security.InvalidKeyException:Failed to unwrap key. 
You need to 
* [disable autobackup](https://developer.android.com/guide/topics/data/autobackup#EnablingAutoBackup), [details](https://github.com/mogol/flutter_secure_storage/issues/13#issuecomment-421083742)
* [exclude sharedprefs](https://developer.android.com/guide/topics/data/autobackup#IncludingFiles) `FlutterSecureStorage` used by the plugin, [details](https://github.com/mogol/flutter_secure_storage/issues/43#issuecomment-471642126)

## Configure iOS version
**Important:** if you are coming from a previous version of `flutter_secure_storage` then you need to use the new `migrate` function to migrate the entries from the keychain into the new `Valet` sandbox, which wraps the calls to keychain. This is ignored on android so you are free to call it like the example below.

This only needs to be done once, and is best done in your `main()` method, awaiting it before starting your app:
```dart
Future<void> main() async {
  /// Migrate if necessary
  await _storage.migrate();

  runApp(MaterialApp(home: ItemsWidget()));
}
```

If you use custom `groupId`(s) then you need to call `migrate` for each one, and also for each `IOSAccessibility` you use.

If you just use the default `groupId` (empty), and the default `IOSAccessibility.unlocked`, then all you need to do is call `await _storage.migrate()` and you are done.

Example for multiple groupIds and accessibility options:
```dart
Future<void> main() async {
  /// Migrate all possible entries
  for (accessibility in [IOSAccessibility.unlocked, IOSAccessibility.passcode]) {
    for (groupId in ['first_group', 'second_group']) {
      await _storage.migrate(
        iOptions: IOSOptions(
          groupId: groupId,
          accessibility: accessibility,
        ),
      );
    }
  }

  runApp(MaterialApp(home: ItemsWidget()));
}
```

You'll want to keep this in your app until you're reasonably sure everybody has migrated, otherwise your app will think the keychain is empty and it could result in somethign undesirable like logging the users out.

## Integration Tests

Run the following command from `example` directory
```
flutter drive --target=test_driver/app.dart
```