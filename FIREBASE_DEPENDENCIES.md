# Firebase Dependencies for Inventry2

## Required Firebase SDK Packages

Add these packages via Swift Package Manager in Xcode:

### 1. Firebase iOS SDK
**Repository URL:** `https://github.com/firebase/firebase-ios-sdk`

### 2. Required Products to Add:
- `FirebaseAuth` - Authentication
- `FirebaseFirestore` - Firestore database with offline persistence
- `FirebaseStorage` - File and image storage
- `FirebaseCore` - Core Firebase functionality

### 3. Steps to Add in Xcode:

1. Open `Inventry.xcodeproj` in Xcode
2. Go to File → Add Package Dependencies
3. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
4. Select "Up to Next Major Version" with version `11.0.0` or latest
5. Add these specific products to the Inventry target:
   - FirebaseAuth
   - FirebaseFirestore  
   - FirebaseStorage
   - FirebaseCore

### 4. After Adding Packages:

In `InventryApp.swift`, uncomment:
```swift
import FirebaseCore

// In init():
FirebaseApp.configure()
```

In `FirebaseService.swift`, uncomment:
```swift
import FirebaseCore
import FirebaseAuth  
import FirebaseFirestore
import FirebaseStorage

// Private properties:
private let db = Firestore.firestore()
private let auth = Auth.auth()
private let storage = Storage.storage()
```

### 5. Enable Offline Persistence:

Once packages are added, Firestore will automatically use offline persistence for better performance.

---

**Note:** This is ready to go - just add the packages and uncomment the imports!