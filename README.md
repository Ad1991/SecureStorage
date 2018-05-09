# SecureStorage

A lightweight library that lets you store any swift type with AES 256 encryption. Encryption keys are generated at runtime and stored in device keychain.

## Installation

`SecureStorage`  can be installed via CocoaPods:

```ruby
target 'ProjectName' do
    pod 'SecureStorage'
end
```

## Usage 

`SecureStorage` allows you to store you swift type in `UserDefaults`, shared defaults or on disk. Shared defaults allow you to share data among applications. Encryption keys can also be stored in shared keychain to enable sharing keys among applications.

### Initialization

`SecureStorage` initialization has three parts:

#### Storage Location

You can choose storage location during initialization. Available values are:

- **UserDefaults**: This is the default storage location. It is used when no storage location is provided.

  ```swift
  let secureStorage = SecureStorage(keychainAccessGroup: nil)
  ```

* **File location**: If a folder path is provided during initialization, encrypted data will be stored as files in that folder. Keys will be used as file names. Throws initialization failed error if a file already exists at provided location or if the location is not a directory.

  ```swift
  let secureStorage = try! SecureStorage(fileLocation: fileLocation, keychainAccessGroup: nil)
  ```

* **Shared defaults**: `SecureStorage` also allows you to store encrypted data in shared defaults to enable sharing encrypted data among applications. You need to enable App Groups in your application's capabilities and provide the app group identifier to `SecureStorage` during initialization. Throws initialization failed error if shared defaults could not be initialized.

  ```swift
  let secureStorage = try! SecureStorage(sharedDefaultsId: "group.com.your.company.YourApp", keychainAccessGroup: nil)
  ```

#### Keychain Group

You can choose to store encryption keys in shared keychain to enable sharing of keys among applications. This can be used in conjuntion with shared defaults to share encrypted objects among applications. To use this option, you need to enable Keychain sharing in your application capabilities and provide Keychain group identifier during `SecureStorage` initialization.

```swift
// Below initialization stores data in shared defalults
// and encryption keys are stored in shared keychain
let secureStorage = try! SecureStorage(sharedDefaultsId: "group.com.your.company.YourApp", keychainAccessGroup: "your.keychain.sharing.identifier")
```

#### Keychain Access Control

`SecureStorage` also allows applications to set keychain access level policy. Default value is set to strictest policy `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly `. If you need to choose a different policy you can choose that during initialization.

```swift
let secureStorage = SecureStorage(keychainAccessGroup: nil, keychainAccessControl: kSecAttrAccessibleAlways)
```

### Accessing Objects

Post initialization, storing and retrieving swift types from `SecureStorage` is very simple.

```swift
// Initialize SecureStorage
let secureStorage = SecureStorage(keychainAccessGroup: nil)
// Store data
try secureStorage.store(textViewToStore.text, for: keyForStorage)
// retrieve data
let text = try secureStorage.fetchObject(for: keyForStorage)
// delete data
secureStorage.removeObject(for: keyForStorage)
```



## License

SecureStorage is released under MIT License.