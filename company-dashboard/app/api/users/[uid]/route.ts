import { NextRequest, NextResponse } from 'next/server'
import { adminAuth, adminDb } from '@/lib/firebase-admin'

// GET: Get specific user
export async function GET(
  request: NextRequest,
  { params }: { params: { uid: string } }
) {
  try {
    const { uid } = params
    console.log('👤 Fetching user:', uid)
    
    // Get user from Firebase Auth
    const userRecord = await adminAuth.getUser(uid)
    
    // Get additional user data from Firestore
    let userData = null
    try {
      const userDoc = await adminDb.collection('users').doc(uid).get()
      if (userDoc.exists) {
        userData = userDoc.data()
      }
    } catch (error) {
      console.warn(`Could not fetch user data for ${uid}:`, error)
    }

    const user = {
      uid: userRecord.uid,
      email: userRecord.email,
      emailVerified: userRecord.emailVerified,
      displayName: userRecord.displayName,
      disabled: userRecord.disabled,
      creationTime: userRecord.metadata.creationTime,
      lastSignInTime: userRecord.metadata.lastSignInTime,
      customClaims: userRecord.customClaims || {},
      // Additional data from Firestore
      role: userData?.role || 'client',
      company: userData?.company || null,
      phone: userData?.phone || null,
      address: userData?.address || null,
      propertiesCount: userData?.propertiesCount || 0,
    }

    console.log('✅ User found:', user.email)
    
    return NextResponse.json({
      success: true,
      user
    })
    
  } catch (error) {
    console.error('❌ Error fetching user:', error)
    
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to fetch user',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 404 }
    )
  }
}

// PUT: Update user
export async function PUT(
  request: NextRequest,
  { params }: { params: { uid: string } }
) {
  try {
    const { uid } = params
    const body = await request.json()
    const { displayName, role, company, phone, address, disabled } = body

    console.log('✏️ Updating user:', uid, body)

    // Update user in Firebase Auth
    const updateData: any = {}
    if (displayName !== undefined) updateData.displayName = displayName
    if (disabled !== undefined) updateData.disabled = disabled

    if (Object.keys(updateData).length > 0) {
      await adminAuth.updateUser(uid, updateData)
    }

    // Update custom claims if role changed
    if (role) {
      await adminAuth.setCustomUserClaims(uid, { role })
    }

    // Update additional data in Firestore
    const firestoreUpdateData: any = {
      lastUpdated: new Date().toISOString(),
    }
    
    if (displayName !== undefined) firestoreUpdateData.displayName = displayName
    if (role !== undefined) firestoreUpdateData.role = role
    if (company !== undefined) firestoreUpdateData.company = company
    if (phone !== undefined) firestoreUpdateData.phone = phone
    if (address !== undefined) firestoreUpdateData.address = address

    await adminDb.collection('users').doc(uid).update(firestoreUpdateData)

    console.log('✅ User updated successfully:', uid)

    return NextResponse.json({
      success: true,
      message: 'User updated successfully'
    })

  } catch (error) {
    console.error('❌ Error updating user:', error)
    
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to update user',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    )
  }
}

// DELETE: Delete user
export async function DELETE(
  request: NextRequest,
  { params }: { params: { uid: string } }
) {
  try {
    const { uid } = params
    console.log('🗑️ Deleting user:', uid)
    
    // Delete user from Firebase Auth
    await adminAuth.deleteUser(uid)
    
    // Delete user data from Firestore
    try {
      await adminDb.collection('users').doc(uid).delete()
    } catch (error) {
      console.warn(`Could not delete user data for ${uid}:`, error)
    }

    console.log('✅ User deleted successfully:', uid)

    return NextResponse.json({
      success: true,
      message: 'User deleted successfully'
    })

  } catch (error) {
    console.error('❌ Error deleting user:', error)
    
    return NextResponse.json(
      { 
        success: false, 
        error: 'Failed to delete user',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    )
  }
}