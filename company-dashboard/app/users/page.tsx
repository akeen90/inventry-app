'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import styles from './users.module.css'

interface User {
  uid: string
  email: string
  emailVerified: boolean
  displayName?: string
  disabled: boolean
  creationTime: string
  lastSignInTime?: string
  role: string
  company?: string
  phone?: string
  address?: string
  propertiesCount: number
}

export default function UsersPage() {
  const router = useRouter()
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [setupRequired, setSetupRequired] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const [showAddModal, setShowAddModal] = useState(false)
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [showEditModal, setShowEditModal] = useState(false)

  // Load users on component mount
  useEffect(() => {
    loadUsers()
  }, [])

  const loadUsers = async () => {
    try {
      setLoading(true)
      setError(null)
      
      const response = await fetch('/api/users')
      const data = await response.json()
      
      if (data.setup_required) {
        setSetupRequired(true)
        setUsers([])
      } else if (data.success) {
        setUsers(data.users)
        setSetupRequired(false)
      } else {
        setError(data.error || 'Failed to load users')
      }
    } catch (err) {
      setError('Failed to connect to server')
      console.error('Error loading users:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleCreateUser = async (userData: any) => {
    try {
      const response = await fetch('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userData)
      })
      
      const result = await response.json()
      
      if (result.success) {
        loadUsers() // Reload the users list
        setShowAddModal(false)
      } else {
        alert('Failed to create user: ' + result.error)
      }
    } catch (err) {
      alert('Failed to create user')
      console.error('Error creating user:', err)
    }
  }

  const handleUpdateUser = async (userData: any) => {
    if (!selectedUser) return
    
    try {
      const response = await fetch(`/api/users/${selectedUser.uid}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userData)
      })
      
      const result = await response.json()
      
      if (result.success) {
        loadUsers() // Reload the users list
        setShowEditModal(false)
        setSelectedUser(null)
      } else {
        alert('Failed to update user: ' + result.error)
      }
    } catch (err) {
      alert('Failed to update user')
      console.error('Error updating user:', err)
    }
  }

  const handleDeleteUser = async (user: User) => {
    if (!confirm(`Are you sure you want to delete user ${user.email}? This action cannot be undone.`)) {
      return
    }
    
    try {
      const response = await fetch(`/api/users/${user.uid}`, {
        method: 'DELETE'
      })
      
      const result = await response.json()
      
      if (result.success) {
        loadUsers() // Reload the users list
      } else {
        alert('Failed to delete user: ' + result.error)
      }
    } catch (err) {
      alert('Failed to delete user')
      console.error('Error deleting user:', err)
    }
  }

  // Filter users based on search term
  const filteredUsers = users.filter(user =>
    user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.displayName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.company?.toLowerCase().includes(searchTerm.toLowerCase())
  )

  // Calculate stats
  const stats = {
    total: users.length,
    verified: users.filter(u => u.emailVerified).length,
    active: users.filter(u => !u.disabled).length,
    clients: users.filter(u => u.role === 'client').length
  }

  if (loading) {
    return (
      <div className={styles.container}>
        <div>Loading users...</div>
      </div>
    )
  }

  if (setupRequired) {
    return (
      <div className={styles.container}>
        <div className={styles.setupMessage}>
          <div className={styles.setupTitle}>🔧 Firebase Setup Required</div>
          <p className={styles.setupText}>
            Firebase Admin SDK is not configured. Please check the FIREBASE_SETUP.md file for setup instructions.
          </p>
          <p className={styles.setupText}>
            You need to configure your Firebase service account credentials in the .env.local file.
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className={styles.container}>
      {/* Header */}
      <div className={styles.header}>
        <div style={{ marginBottom: '16px' }}>
          <button 
            onClick={() => router.push('/')}
            className={styles.backButton}
          >
            ← Back to Dashboard
          </button>
        </div>
        <h1 className={styles.title}>User Management</h1>
        <p className={styles.subtitle}>Manage users from your iOS app and dashboard</p>
      </div>

      {/* Stats */}
      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <div className={styles.statValue}>{stats.total}</div>
          <div className={styles.statLabel}>Total Users</div>
        </div>
        <div className={styles.statCard}>
          <div className={styles.statValue}>{stats.active}</div>
          <div className={styles.statLabel}>Active Users</div>
        </div>
        <div className={styles.statCard}>
          <div className={styles.statValue}>{stats.verified}</div>
          <div className={styles.statLabel}>Verified Emails</div>
        </div>
        <div className={styles.statCard}>
          <div className={styles.statValue}>{stats.clients}</div>
          <div className={styles.statLabel}>Clients</div>
        </div>
      </div>

      {/* Controls */}
      <div className={styles.controls}>
        <input
          type="text"
          placeholder="Search users..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className={styles.searchBox}
        />
        <button
          onClick={() => setShowAddModal(true)}
          className={styles.addButton}
        >
          + Add User
        </button>
      </div>

      {/* Users Table */}
      <table className={styles.table}>
        <thead>
          <tr>
            <th>User</th>
            <th>Email</th>
            <th>Role</th>
            <th>Status</th>
            <th>Created</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {filteredUsers.map(user => (
            <tr key={user.uid}>
              <td>
                <div>{user.displayName || user.email.split('@')[0]}</div>
                {user.company && <div style={{ fontSize: '12px', color: '#666' }}>{user.company}</div>}
              </td>
              <td>{user.email}</td>
              <td>
                <span className={`${styles.roleTag} ${styles[`role${user.role.charAt(0).toUpperCase() + user.role.slice(1)}`]}`}>
                  {user.role}
                </span>
              </td>
              <td>
                <span className={user.emailVerified ? styles.statusVerified : styles.statusUnverified}>
                  {user.emailVerified ? '✓ Verified' : '✗ Unverified'}
                </span>
              </td>
              <td>{new Date(user.creationTime).toLocaleDateString()}</td>
              <td>
                <button
                  onClick={() => {
                    setSelectedUser(user)
                    setShowEditModal(true)
                  }}
                  className={styles.actionButton}
                >
                  Edit
                </button>
                <button
                  onClick={() => handleDeleteUser(user)}
                  className={`${styles.actionButton} ${styles.deleteButton}`}
                >
                  Delete
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {filteredUsers.length === 0 && searchTerm && (
        <div style={{ textAlign: 'center', padding: '40px', color: '#666' }}>
          No users found matching "{searchTerm}"
        </div>
      )}

      {/* Add User Modal */}
      {showAddModal && (
        <UserModal
          title="Add New User"
          onSave={handleCreateUser}
          onCancel={() => setShowAddModal(false)}
        />
      )}

      {/* Edit User Modal */}
      {showEditModal && selectedUser && (
        <UserModal
          title="Edit User"
          user={selectedUser}
          onSave={handleUpdateUser}
          onCancel={() => {
            setShowEditModal(false)
            setSelectedUser(null)
          }}
        />
      )}
    </div>
  )
}

// User Modal Component
function UserModal({ title, user, onSave, onCancel }: {
  title: string
  user?: User
  onSave: (userData: any) => void
  onCancel: () => void
}) {
  const [formData, setFormData] = useState({
    email: user?.email || '',
    password: '',
    displayName: user?.displayName || '',
    role: user?.role || 'client',
    company: user?.company || '',
    phone: user?.phone || '',
    address: user?.address || ''
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    onSave(formData)
  }

  return (
    <div className={styles.modal}>
      <div className={styles.modalContent}>
        <h2 className={styles.modalTitle}>{title}</h2>
        <form onSubmit={handleSubmit}>
          <div className={styles.formGroup}>
            <label className={styles.label}>Email *</label>
            <input
              type="email"
              required
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              className={styles.input}
              disabled={!!user} // Disable email editing for existing users
            />
          </div>

          {!user && (
            <div className={styles.formGroup}>
              <label className={styles.label}>Password *</label>
              <input
                type="password"
                required
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                className={styles.input}
                minLength={6}
              />
            </div>
          )}

          <div className={styles.formGroup}>
            <label className={styles.label}>Display Name</label>
            <input
              type="text"
              value={formData.displayName}
              onChange={(e) => setFormData({ ...formData, displayName: e.target.value })}
              className={styles.input}
            />
          </div>

          <div className={styles.formGroup}>
            <label className={styles.label}>Role</label>
            <select
              value={formData.role}
              onChange={(e) => setFormData({ ...formData, role: e.target.value })}
              className={styles.select}
            >
              <option value="client">Client</option>
              <option value="manager">Manager</option>
              <option value="admin">Admin</option>
            </select>
          </div>

          <div className={styles.formGroup}>
            <label className={styles.label}>Company</label>
            <input
              type="text"
              value={formData.company}
              onChange={(e) => setFormData({ ...formData, company: e.target.value })}
              className={styles.input}
            />
          </div>

          <div className={styles.formGroup}>
            <label className={styles.label}>Phone</label>
            <input
              type="tel"
              value={formData.phone}
              onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              className={styles.input}
            />
          </div>

          <div className={styles.formGroup}>
            <label className={styles.label}>Address</label>
            <input
              type="text"
              value={formData.address}
              onChange={(e) => setFormData({ ...formData, address: e.target.value })}
              className={styles.input}
            />
          </div>

          <div className={styles.modalActions}>
            <button type="button" onClick={onCancel} className={styles.cancelButton}>
              Cancel
            </button>
            <button type="submit" className={styles.saveButton}>
              {user ? 'Update User' : 'Create User'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}