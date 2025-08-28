import { NextRequest, NextResponse } from 'next/server'
import { adminAuth, adminDb, isAdminInitialized } from '@/lib/firebase-admin'

// GET: Test Firebase connection and check for existing users
export async function GET(request: NextRequest) {
  try {
    console.log('🧪 Testing Firebase Admin connection...')
    
    if (!isAdminInitialized()) {
      return NextResponse.json({
        success: false,
        firebase_admin_initialized: false,
        error: 'Firebase Admin not initialized',
        timestamp: new Date().toISOString(),
        notes: [
          'Firebase Admin SDK requires service account credentials',
          'Check .env.local file configuration',
          'Restart server after adding credentials'
        ]
      })
    }
    
    // Test Firebase Admin Auth connection
    const authUsers = await adminAuth.listUsers(10) // Get first 10 users
    
    // Test Firebase Admin Firestore connection
    const usersCollection = adminDb.collection('users')
    const userDocs = await usersCollection.limit(5).get()
    
    const firestoreUsers = userDocs.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      createdAt: doc.data().createdAt || 'Unknown'
    }))
    
    const results = {
      success: true,
      firebase_admin_initialized: true,
      auth_users: {
        count: authUsers.users.length,
        users: authUsers.users.slice(0, 3).map(user => ({
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          emailVerified: user.emailVerified,
          creationTime: user.metadata.creationTime,
          lastSignInTime: user.metadata.lastSignInTime
        }))
      },
      firestore_users: {
        count: firestoreUsers.length,
        users: firestoreUsers
      },
      timestamp: new Date().toISOString(),
      notes: [
        '✅ Firebase Admin SDK working correctly',
        'Users from iOS app should appear in auth_users',
        'User management dashboard is ready to use'
      ]
    }
    
    console.log('✅ Firebase test successful:', results)
    
    return NextResponse.json(results)
    
  } catch (error) {
    console.error('❌ Firebase test failed:', error)
    
    return NextResponse.json({
      success: false,
      firebase_connected: false,
      error: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString(),
      notes: [
        'Firebase connection failed',
        'Check Firebase configuration in lib/firebase.ts',
        'Ensure Firebase project is properly configured'
      ]
    }, { status: 500 })
  }
}