'use client'

import { useEffect, useState } from 'react'
import { db } from '../lib/firebase'
import { InventryDataService, type PropertyInventory, type Property } from '../lib/data-services'

export default function ClientDashboard() {
  const [inventories, setInventories] = useState<PropertyInventory[]>([])
  const [properties, setProperties] = useState<Property[]>([])
  const [stats, setStats] = useState({
    totalProperties: 0,
    inProgress: 0,
    completed: 0
  })
  const [loading, setLoading] = useState(true)

  // For demo purposes, we'll use John Smith's client ID
  const CLIENT_ID = 'john-smith-demo' // In a real app, this would come from authentication

  useEffect(() => {
    const dataService = new InventryDataService(db)
    
    // Load initial data
    const loadData = async () => {
      try {
        const [clientInventories, clientProperties, clientStats] = await Promise.all([
          dataService.getClientInventories(CLIENT_ID),
          dataService.getClientProperties(CLIENT_ID), 
          dataService.getClientStats(CLIENT_ID)
        ])

        setInventories(clientInventories)
        setProperties(clientProperties)
        setStats(clientStats)
      } catch (error) {
        console.error('Error loading client data:', error)
      } finally {
        setLoading(false)
      }
    }

    loadData()

    // Set up real-time listener for inventories
    const unsubscribe = dataService.subscribeToClientInventories(CLIENT_ID, (updatedInventories) => {
      setInventories(updatedInventories)
      // Recalculate stats
      const totalProperties = updatedInventories.length
      const inProgress = updatedInventories.filter(inv => inv.status === 'in-progress').length
      const completed = updatedInventories.filter(inv => inv.status === 'completed').length
      setStats({ totalProperties, inProgress, completed })
    })

    return () => unsubscribe()
  }, [])

  if (loading) {
    return (
      <div style={{
        minHeight: '100vh',
        backgroundColor: '#f8fafc',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        fontFamily: 'system-ui, -apple-system, sans-serif'
      }}>
        <div style={{
          padding: '40px',
          backgroundColor: 'white',
          borderRadius: '16px',
          boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
          textAlign: 'center'
        }}>
          <div style={{
            width: '40px',
            height: '40px',
            border: '4px solid #e5e7eb',
            borderTop: '4px solid #2563eb',
            borderRadius: '50%',
            animation: 'spin 1s linear infinite',
            margin: '0 auto 16px'
          }}></div>
          <p style={{ color: '#6b7280', margin: 0 }}>Loading your properties...</p>
        </div>
        <style jsx>{`
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    )
  }

  return (
    <div style={{
      minHeight: '100vh',
      backgroundColor: '#f8fafc',
      fontFamily: 'system-ui, -apple-system, sans-serif'
    }}>
      {/* Header */}
      <header style={{
        backgroundColor: 'white',
        boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.1)',
        borderBottom: '1px solid #e5e7eb'
      }}>
        <div style={{
          maxWidth: '1280px',
          margin: '0 auto',
          padding: '16px 24px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{
              width: '40px',
              height: '40px',
              background: 'linear-gradient(135deg, #2563eb, #1d4ed8)',
              borderRadius: '12px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'white',
              fontWeight: 'bold',
              fontSize: '18px'
            }}>
              I
            </div>
            <div>
              <h1 style={{
                fontSize: '24px',
                fontWeight: 'bold',
                color: '#111827',
                margin: 0
              }}>
                Inventry
              </h1>
              <p style={{
                fontSize: '14px',
                color: '#2563eb',
                margin: 0
              }}>
                Client Portal
              </p>
            </div>
          </div>
          
          <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div style={{ textAlign: 'right' }}>
              <p style={{
                fontSize: '16px',
                fontWeight: '600',
                color: '#111827',
                margin: 0
              }}>
                John Smith
              </p>
              <p style={{
                fontSize: '14px',
                color: '#6b7280',
                margin: 0
              }}>
                Property Owner
              </p>
            </div>
            <div style={{
              width: '48px',
              height: '48px',
              background: 'linear-gradient(135deg, #10b981, #059669)',
              borderRadius: '50%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'white',
              fontWeight: 'bold',
              fontSize: '18px'
            }}>
              JS
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main style={{
        maxWidth: '1280px',
        margin: '0 auto',
        padding: '32px 24px'
      }}>
        {/* Welcome Banner */}
        <div style={{
          background: 'linear-gradient(135deg, #2563eb, #1d4ed8)',
          borderRadius: '16px',
          padding: '32px',
          color: 'white',
          marginBottom: '32px',
          boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1)'
        }}>
          <h2 style={{
            fontSize: '32px',
            fontWeight: 'bold',
            margin: '0 0 12px 0'
          }}>
            Welcome back, John!
          </h2>
          <p style={{
            fontSize: '18px',
            color: 'rgba(255, 255, 255, 0.8)',
            margin: 0
          }}>
            {inventories.length > 0 
              ? `You have ${stats.inProgress} inventories in progress and ${stats.completed} completed`
              : 'Your property inventory dashboard is ready'
            }
          </p>
        </div>

        {/* Stats Cards */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
          gap: '24px',
          marginBottom: '32px'
        }}>
          <div style={{
            backgroundColor: 'white',
            padding: '24px',
            borderRadius: '16px',
            boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
            border: '1px solid #f3f4f6'
          }}>
            <div style={{ display: 'flex', alignItems: 'center' }}>
              <div style={{
                width: '48px',
                height: '48px',
                backgroundColor: '#dbeafe',
                borderRadius: '12px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
              }}>
                <div style={{
                  width: '24px',
                  height: '24px',
                  backgroundColor: '#2563eb',
                  borderRadius: '4px'
                }}></div>
              </div>
              <div style={{ marginLeft: '16px' }}>
                <p style={{
                  fontSize: '14px',
                  fontWeight: '500',
                  color: '#6b7280',
                  textTransform: 'uppercase',
                  letterSpacing: '0.05em',
                  margin: '0 0 4px 0'
                }}>
                  Total Properties
                </p>
                <p style={{
                  fontSize: '32px',
                  fontWeight: 'bold',
                  color: '#111827',
                  margin: 0
                }}>
                  {stats.totalProperties}
                </p>
              </div>
            </div>
          </div>

          <div style={{
            backgroundColor: 'white',
            padding: '24px',
            borderRadius: '16px',
            boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
            border: '1px solid #f3f4f6'
          }}>
            <div style={{ display: 'flex', alignItems: 'center' }}>
              <div style={{
                width: '48px',
                height: '48px',
                backgroundColor: '#fef3c7',
                borderRadius: '12px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
              }}>
                <div style={{
                  width: '24px',
                  height: '24px',
                  backgroundColor: '#d97706',
                  borderRadius: '50%'
                }}></div>
              </div>
              <div style={{ marginLeft: '16px' }}>
                <p style={{
                  fontSize: '14px',
                  fontWeight: '500',
                  color: '#6b7280',
                  textTransform: 'uppercase',
                  letterSpacing: '0.05em',
                  margin: '0 0 4px 0'
                }}>
                  In Progress
                </p>
                <p style={{
                  fontSize: '32px',
                  fontWeight: 'bold',
                  color: '#111827',
                  margin: 0
                }}>
                  {stats.inProgress}
                </p>
              </div>
            </div>
          </div>

          <div style={{
            backgroundColor: 'white',
            padding: '24px',
            borderRadius: '16px',
            boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
            border: '1px solid #f3f4f6'
          }}>
            <div style={{ display: 'flex', alignItems: 'center' }}>
              <div style={{
                width: '48px',
                height: '48px',
                backgroundColor: '#d1fae5',
                borderRadius: '12px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
              }}>
                <div style={{
                  width: '20px',
                  height: '20px',
                  backgroundColor: '#10b981',
                  borderRadius: '50%'
                }}></div>
              </div>
              <div style={{ marginLeft: '16px' }}>
                <p style={{
                  fontSize: '14px',
                  fontWeight: '500',
                  color: '#6b7280',
                  textTransform: 'uppercase',
                  letterSpacing: '0.05em',
                  margin: '0 0 4px 0'
                }}>
                  Completed
                </p>
                <p style={{
                  fontSize: '32px',
                  fontWeight: 'bold',
                  color: '#111827',
                  margin: 0
                }}>
                  {stats.completed}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Properties List */}
        <div style={{
          backgroundColor: 'white',
          borderRadius: '16px',
          boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1)',
          border: '1px solid #f3f4f6'
        }}>
          <div style={{
            padding: '24px 32px',
            borderBottom: '1px solid #e5e7eb'
          }}>
            <h3 style={{
              fontSize: '24px',
              fontWeight: 'bold',
              color: '#111827',
              margin: '0 0 4px 0'
            }}>
              Your Properties
            </h3>
            <p style={{
              color: '#6b7280',
              margin: 0
            }}>
              {inventories.length > 0 
                ? 'Manage and track your property inventories'
                : 'No inventories found. Your properties will appear here once they are added.'
              }
            </p>
          </div>
          
          <div style={{ padding: '32px' }}>
            {inventories.length === 0 ? (
              <div style={{
                textAlign: 'center',
                padding: '40px',
                color: '#6b7280'
              }}>
                <div style={{
                  width: '80px',
                  height: '80px',
                  backgroundColor: '#f3f4f6',
                  borderRadius: '50%',
                  margin: '0 auto 16px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <div style={{
                    width: '40px',
                    height: '40px',
                    backgroundColor: '#9ca3af',
                    borderRadius: '6px'
                  }}></div>
                </div>
                <h4 style={{ margin: '0 0 8px 0', fontSize: '18px', fontWeight: '600' }}>
                  No Properties Yet
                </h4>
                <p style={{ margin: 0 }}>
                  Your property inventories will be displayed here once they are created.
                </p>
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
                {inventories.map((inventory) => {
                  const statusConfig = {
                    completed: { label: '✓ Complete', color: '#065f46', bg: '#d1fae5' },
                    'in-progress': { label: '⏳ In Progress', color: '#92400e', bg: '#fef3c7' },
                    scheduled: { label: '📅 Scheduled', color: '#374151', bg: '#f3f4f6' }
                  }

                  const config = statusConfig[inventory.status] || statusConfig.scheduled

                  return (
                    <div key={inventory.id} style={{
                      border: '1px solid #e5e7eb',
                      borderRadius: '12px',
                      padding: '24px',
                      transition: 'box-shadow 0.2s'
                    }}>
                      <div style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'space-between',
                        marginBottom: '16px'
                      }}>
                        <div>
                          <h4 style={{
                            fontSize: '20px',
                            fontWeight: '600',
                            color: '#111827',
                            margin: '0 0 4px 0'
                          }}>
                            {inventory.propertyId} {/* In real app, we'd look up property name */}
                          </h4>
                          <p style={{
                            color: '#6b7280',
                            margin: '0 0 4px 0'
                          }}>
                            Type: {inventory.type.charAt(0).toUpperCase() + inventory.type.slice(1).replace('-', ' ')}
                          </p>
                          <p style={{
                            color: '#6b7280',
                            margin: 0,
                            fontSize: '14px'
                          }}>
                            {inventory.scheduledDate && `Scheduled: ${inventory.scheduledDate.toLocaleDateString()}`}
                            {inventory.startDate && `Started: ${inventory.startDate.toLocaleDateString()}`}
                            {inventory.completedDate && `Completed: ${inventory.completedDate.toLocaleDateString()}`}
                          </p>
                        </div>
                        <span style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          padding: '8px 16px',
                          borderRadius: '20px',
                          fontSize: '14px',
                          fontWeight: '500',
                          backgroundColor: config.bg,
                          color: config.color
                        }}>
                          {config.label}
                        </span>
                      </div>
                      
                      {inventory.status !== 'scheduled' && (
                        <div>
                          <div style={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            fontSize: '14px',
                            marginBottom: '8px'
                          }}>
                            <span style={{ color: '#6b7280', fontWeight: '500' }}>Progress</span>
                            <span style={{ 
                              fontWeight: 'bold', 
                              color: inventory.status === 'completed' ? '#10b981' : '#2563eb' 
                            }}>
                              {inventory.progress}%
                            </span>
                          </div>
                          <div style={{
                            width: '100%',
                            backgroundColor: '#e5e7eb',
                            borderRadius: '6px',
                            height: '12px'
                          }}>
                            <div style={{
                              background: inventory.status === 'completed' 
                                ? 'linear-gradient(90deg, #10b981, #059669)'
                                : 'linear-gradient(90deg, #2563eb, #1d4ed8)',
                              height: '12px',
                              borderRadius: '6px',
                              width: `${inventory.progress}%`
                            }}></div>
                          </div>
                        </div>
                      )}
                      
                      {inventory.notes && (
                        <div style={{ marginTop: '12px' }}>
                          <p style={{
                            fontSize: '14px',
                            color: '#6b7280',
                            margin: 0,
                            fontStyle: 'italic'
                          }}>
                            "{inventory.notes}"
                          </p>
                        </div>
                      )}
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  )
}