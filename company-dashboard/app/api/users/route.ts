import { NextRequest, NextResponse } from 'next/server'
import { adminAuth, adminDb, isAdminInitialized, getAdminError } from '@/lib/firebase-admin'

// GET: List all users
export async function GET(request: NextRequest) {
  try {
    console.log('📋 Fetching all users...')
    
    // Check if Firebase Admin is initialized
    if (!isAdminInitialized()) {
      console.warn('⚠️  Firebase Admin not initialized')
      return NextResponse.json({
        success: false,
        error: getAdminError(),
        users: [],
        total: 0,
        setup_required: true
      })
    }
    
    // Get users from Firebase Auth
    const usersList = await adminAuth.listUsers()
    
    // Get additional user data from Firestore
    const usersWithData = await Promise.all(
      usersList.users.map(async (user) => {
        let userData = null
        
        try {
          const userDoc = await adminDb.collection('users').doc(user.uid).get()
          if (userDoc.exists) {
            userData = userDoc.data()
          }
        } catch (error) {
          console.warn(`Could not fetch user data for ${user.uid}:`, error)
        }

        return {
          uid: user.uid,
          email: user.email,
          emailVerified: user.emailVerified,
          displayName: user.displayName,
          disabled: user.disabled,
          creationTime: user.metadata.creationTime,
          lastSignInTime: user.metadata.lastSignInTime,
          customClaims: user.customClaims || {},
          // Additional data from Firestore
          role: userData?.role || 'client',
          company: userData?.company || null,
          phone: userData?.phone || null,
          address: userData?.address || null,
          propertiesCount: userData?.propertiesCount || 0,
        }
      })
    )

    console.log(`✅ Found ${usersWithData.length} users`)
    
    return NextResponse.json({
      success: true,
      users: usersWithData,
      total: usersWithData.length
    })
    
  } catch (error) {
    console.error('❌ Error fetching users:', error)
    
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to fetch users',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    )
  }
}

// POST: Create new user
export async function POST(request: NextRequest) {
  try {
    // Check if Firebase Admin is initialized
    if (!isAdminInitialized()) {
      return NextResponse.json({
        success: false,
        error: getAdminError(),
        setup_required: true
      }, { status: 503 })
    }
    
    const body = await request.json()
    const { email, password, displayName, role = 'client', company, phone, address } = body

    console.log('👤 Creating new user:', { email, displayName, role })

    // Validate required fields
    if (!email || !password) {
      return NextResponse.json(
        { success: false, error: 'Email and password are required' },
        { status: 400 }
      )
    }

    // Create user in Firebase Auth
    const userRecord = await adminAuth.createUser({
      email,
      password,
      displayName,
      emailVerified: false,
    })

    // Set custom claims for role-based access
    await adminAuth.setCustomUserClaims(userRecord.uid, { role })

    // Store additional user data in Firestore
    await adminDb.collection('users').doc(userRecord.uid).set({
      email,
      displayName: displayName || email.split('@')[0],
      role,
      company: company || null,
      phone: phone || null,
      address: address || null,
      createdAt: new Date().toISOString(),
      propertiesCount: 0,
      lastUpdated: new Date().toISOString(),
    })

    console.log('✅ User created successfully:', userRecord.uid)

    return NextResponse.json({
      success: true,
      user: {
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName,
        role,
        company,
        phone,
        address,
      }
    })

  } catch (error) {
    console.error('❌ Error creating user:', error)
    
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to create user',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    )
  }
}