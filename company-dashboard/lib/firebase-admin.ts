import { initializeApp, getApps, cert, ServiceAccount } from 'firebase-admin/app'
import { getAuth } from 'firebase-admin/auth'
import { getFirestore } from 'firebase-admin/firestore'

let adminApp: any = null
let adminAuth: any = null
let adminDb: any = null

try {
  // Firebase Admin configuration
  const serviceAccount: ServiceAccount = {
    projectId: "inventoryapp-55dd5",
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL || "",
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n') || "",
  }

  // Only initialize if we have valid credentials
  if (serviceAccount.clientEmail && serviceAccount.privateKey && serviceAccount.privateKey !== "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7VJTUt9Us8cKBxdJXHFrbrHCJHJO3mUzHs4h8RZ3+k7Q2VRIJlQUXfCfV7VrE8XYFvN+5zxH8wAqHyVRnZjfD2\\nKp5H8PQGEyHhKxD\\n-----END PRIVATE KEY-----\\n") {
    // Initialize Firebase Admin (only once)
    adminApp = getApps().length === 0 ? initializeApp({
      credential: cert(serviceAccount),
      projectId: "inventoryapp-55dd5",
    }) : getApps()[0]

    // Initialize Firebase Admin services
    adminAuth = getAuth(adminApp)
    adminDb = getFirestore(adminApp)
    
    console.log('🔥 Firebase Admin initialized for Company Dashboard')
  } else {
    console.warn('⚠️  Firebase Admin not initialized - missing service account credentials')
    console.log('Please set up FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY environment variables')
    console.log('Get these from: Firebase Console > Project Settings > Service Accounts > Generate New Private Key')
  }
} catch (error) {
  console.error('❌ Firebase Admin initialization failed:', error)
  console.log('Please check your Firebase Admin credentials in .env.local')
}

// Create mock implementations if admin is not available
const createMockResponse = (operation: string) => {
  throw new Error(`Firebase Admin not initialized. Cannot perform ${operation}. Please configure service account credentials.`)
}

// Export services with fallback error handling
export { adminAuth, adminDb }
export default adminApp

// Export helper functions for better error handling
export const isAdminInitialized = () => adminApp !== null
export const getAdminError = () => adminApp === null ? 'Firebase Admin not initialized - missing service account credentials' : null