'use client'

import { useState, useEffect } from 'react'
import { 
  User,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
  onAuthStateChanged
} from 'firebase/auth'
import { auth } from '../lib/firebase'

export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user)
      setLoading(false)
      console.log('Auth state changed:', user?.email || 'No user')
    })

    return () => unsubscribe()
  }, [])

  const signIn = async (email: string, password: string) => {
    try {
      const result = await signInWithEmailAndPassword(auth, email, password)
      console.log('Sign in successful:', result.user.email)
      return result.user
    } catch (error) {
      console.error('Sign in error:', error)
      throw error
    }
  }

  const signUp = async (email: string, password: string) => {
    try {
      const result = await createUserWithEmailAndPassword(auth, email, password)
      console.log('Sign up successful:', result.user.email)
      return result.user
    } catch (error) {
      console.error('Sign up error:', error)
      throw error
    }
  }

  const logout = async () => {
    try {
      await signOut(auth)
      console.log('Sign out successful')
    } catch (error) {
      console.error('Sign out error:', error)
      throw error
    }
  }

  return {
    user,
    loading,
    signIn,
    signUp,
    logout
  }
}