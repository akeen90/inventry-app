import { initializeApp, getApps, getApp } from 'firebase/app'
import { getAuth } from 'firebase/auth'
import { getFirestore } from 'firebase/firestore'
import { getStorage } from 'firebase/storage'

const firebaseConfig = {
  apiKey: "AIzaSyC3XYkk4BTZS8p0pxHJ7G2ZwKqhr7OY82I",
  authDomain: "inventoryapp-55dd5.firebaseapp.com",
  projectId: "inventoryapp-55dd5",
  storageBucket: "inventoryapp-55dd5.firebasestorage.app",
  messagingSenderId: "927076110185",
  appId: "1:927076110185:web:954bac1c97640557d0b7f8",
  measurementId: "G-VDEZ23TMT5"
}

// Initialize Firebase (only once)
const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApp()

// Initialize Firebase services
export const auth = getAuth(app)
export const db = getFirestore(app)
export const storage = getStorage(app)

// Export the app
export default app

console.log('Firebase initialized for Client Dashboard')