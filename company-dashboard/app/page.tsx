'use client'

import { useEffect, useState } from 'react'
import { db } from '../lib/firebase'
import { InventryDataService, type PropertyInventory, type Property, type Client, seedSampleData } from '../lib/data-services'

export default function Dashboard() {
  const [inventories, setInventories] = useState<PropertyInventory[]>([])
  const [properties, setProperties] = useState<Property[]>([])
  const [clients, setClients] = useState<Client[]>([])
  const [stats, setStats] = useState({
    totalProperties: 0,
    totalClients: 0,
    inProgress: 0,
    completed: 0,
    completionRate: 0
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const dataService = new InventryDataService(db)

    // Load initial data
    const loadData = async () => {
      try {
        console.log('Starting to load company data...')
        const [allInventories, allProperties, allClients, companyStats] = await Promise.all([
          dataService.getAllInventories(),
          dataService.getAllProperties(),
          dataService.getAllClients(),
          dataService.getCompanyStats()
        ])
        console.log('Data loaded:', { 
          inventories: allInventories.length, 
          properties: allProperties.length, 
          clients: allClients.length 
        })

        // If no data exists, seed sample data
        if (allInventories.length === 0 && allProperties.length === 0 && allClients.length === 0) {
          console.log('No data found, seeding sample data...')
          await seedSampleData(dataService)
          // Reload data after seeding
          const [newInventories, newProperties, newClients, newStats] = await Promise.all([
            dataService.getAllInventories(),
            dataService.getAllProperties(),
            dataService.getAllClients(),
            dataService.getCompanyStats()
          ])
          setInventories(newInventories)
          setProperties(newProperties)
          setClients(newClients)
          setStats(newStats)
        } else {
          setInventories(allInventories)
          setProperties(allProperties)
          setClients(allClients)
          setStats(companyStats)
        }
      } catch (error) {
        console.error('Error loading company data:', error)
      } finally {
        setLoading(false)
      }
    }

    loadData()

    // Set up real-time listener for all inventories
    const unsubscribe = dataService.subscribeToAllInventories((updatedInventories) => {
      setInventories(updatedInventories)
      // Recalculate stats
      const completed = updatedInventories.filter(inv => inv.status === 'completed').length
      const inProgress = updatedInventories.filter(inv => inv.status === 'in-progress').length
      const total = updatedInventories.length
      setStats(prev => ({
        ...prev,
        inProgress,
        completed,
        completionRate: total > 0 ? Math.round((completed / total) * 100) : 0
      }))
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
          <p style={{ color: '#6b7280', margin: 0 }}>Loading company dashboard...</p>
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
      padding: '32px',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      display: 'flex',
      flexDirection: 'column',
      gap: '32px',
      minHeight: '100vh',
      backgroundColor: '#f8fafc'
    }}>
      {/* Modern Page Header */}
      <div style={{
        backgroundColor: 'white',
        borderRadius: '16px',
        boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
        padding: '32px',
        border: '1px solid #f3f4f6'
      }}>
        <div style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between'
        }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '8px' }}>
              <img 
                src="/inventry-icon.png"
                alt="Inventry"
                style={{
                  width: '40px',
                  height: '40px',
                  borderRadius: '12px'
                }}
              />
              <h1 style={{
                fontSize: '32px',
                fontWeight: 'bold',
                color: '#111827',
                margin: 0
              }}>
                Inventry Company Dashboard
              </h1>
            </div>
            <p style={{
              color: '#6b7280',
              fontSize: '18px',
              margin: 0
            }}>
              Manage all properties and clients across your organization
            </p>
          </div>
          <div style={{
            display: 'flex',
            gap: '16px'
          }}>
            <a href="/users" style={{
              display: 'inline-block',
              background: 'linear-gradient(135deg, #059669, #047857)',
              color: 'white',
              padding: '12px 24px',
              borderRadius: '12px',
              fontWeight: '600',
              fontSize: '16px',
              textDecoration: 'none',
              cursor: 'pointer',
              transition: 'all 0.2s',
              boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
            }}>
              👥 Manage Users
            </a>
            <a href="/add-client" style={{
              display: 'inline-block',
              background: 'linear-gradient(135deg, #2563eb, #1d4ed8)',
              color: 'white',
              padding: '12px 24px',
              borderRadius: '12px',
              fontWeight: '600',
              fontSize: '16px',
              textDecoration: 'none',
              cursor: 'pointer',
              transition: 'all 0.2s',
              boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
            }}>
              + Add Client
            </a>
          </div>
        </div>
      </div>

      {/* Enhanced Key Metrics */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
        gap: '24px'
      }}>
        <div style={{
          backgroundColor: 'white',
          padding: '24px',
          borderRadius: '16px',
          boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
          border: '1px solid #f3f4f6',
          transition: 'box-shadow 0.2s'
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
                margin: '0 0 4px 0'
              }}>
                {stats.totalProperties}
              </p>
              <p style={{
                fontSize: '12px',
                color: '#10b981',
                fontWeight: '500',
                margin: 0
              }}>
                Across all clients
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
                margin: '0 0 4px 0'
              }}>
                {stats.completed}
              </p>
              <p style={{
                fontSize: '12px',
                color: '#10b981',
                fontWeight: '500',
                margin: 0
              }}>
                {stats.completionRate}% completion rate
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
                margin: '0 0 4px 0'
              }}>
                {stats.inProgress}
              </p>
              <p style={{
                fontSize: '12px',
                color: '#d97706',
                fontWeight: '500',
                margin: 0
              }}>
                Active inventories
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
              backgroundColor: '#e0e7ff',
              borderRadius: '12px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}>
              <div style={{
                width: '24px',
                height: '24px',
                backgroundColor: '#7c3aed',
                borderRadius: '6px'
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
                Active Clients
              </p>
              <p style={{
                fontSize: '32px',
                fontWeight: 'bold',
                color: '#111827',
                margin: '0 0 4px 0'
              }}>
                {stats.totalClients}
              </p>
              <p style={{
                fontSize: '12px',
                color: '#7c3aed',
                fontWeight: '500',
                margin: 0
              }}>
                Property owners
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Recent Activity & Client Overview */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: '1fr 1fr',
        gap: '32px'
      }}>
        {/* Recent Inventories */}
        <div style={{
          backgroundColor: 'white',
          borderRadius: '16px',
          boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1)',
          border: '1px solid #f3f4f6'
        }}>
          <div style={{
            padding: '24px 32px',
            borderBottom: '1px solid #e5e7eb'
          }}>
            <h2 style={{
              fontSize: '24px',
              fontWeight: 'bold',
              color: '#111827',
              margin: '0 0 4px 0'
            }}>
              Recent Inventories
            </h2>
            <p style={{
              color: '#6b7280',
              margin: 0
            }}>
              Latest activity across all properties
            </p>
          </div>
          <div style={{ padding: '24px' }}>
            {inventories.length === 0 ? (
              <div style={{
                textAlign: 'center',
                padding: '40px',
                color: '#6b7280'
              }}>
                <p>No inventories found. Sample data will be created automatically.</p>
              </div>
            ) : (
              <div style={{
                display: 'flex',
                flexDirection: 'column',
                gap: '16px'
              }}>
                {inventories.slice(0, 5).map((inventory) => {
                  const statusConfig = {
                    completed: { label: 'Complete', color: '#065f46', bg: '#d1fae5' },
                    'in-progress': { label: 'In Progress', color: '#92400e', bg: '#fef3c7' },
                    scheduled: { label: 'Scheduled', color: '#374151', bg: '#f3f4f6' }
                  }

                  const config = statusConfig[inventory.status] || statusConfig.scheduled
                  const client = clients.find(c => c.id === inventory.clientId)

                  return (
                    <div key={inventory.id} style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '16px',
                      backgroundColor: '#f9fafb',
                      borderRadius: '12px'
                    }}>
                      <div style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '16px'
                      }}>
                        <div style={{
                          width: '40px',
                          height: '40px',
                          backgroundColor: config.bg,
                          borderRadius: '8px',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center'
                        }}>
                          <span style={{
                            color: config.color,
                            fontWeight: 'bold',
                            fontSize: '14px'
                          }}>
                            {inventory.type.charAt(0).toUpperCase()}
                          </span>
                        </div>
                        <div>
                          <p style={{
                            fontWeight: '600',
                            color: '#111827',
                            margin: '0 0 2px 0',
                            fontSize: '16px'
                          }}>
                            {inventory.type.charAt(0).toUpperCase() + inventory.type.slice(1).replace('-', ' ')} Inventory
                          </p>
                          <p style={{
                            fontSize: '14px',
                            color: '#6b7280',
                            margin: 0
                          }}>
                            Client: {client?.name || 'Unknown'}
                          </p>
                        </div>
                      </div>
                      <div style={{ textAlign: 'right' }}>
                        <span style={{
                          padding: '4px 8px',
                          backgroundColor: config.bg,
                          color: config.color,
                          borderRadius: '12px',
                          fontSize: '12px',
                          fontWeight: '500'
                        }}>
                          {config.label}
                        </span>
                        <p style={{
                          fontSize: '12px',
                          color: '#6b7280',
                          margin: '4px 0 0 0'
                        }}>
                          {inventory.progress}% complete
                        </p>
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
            
            <button style={{
              width: '100%',
              marginTop: '24px',
              color: '#2563eb',
              fontWeight: '600',
              padding: '8px',
              backgroundColor: 'transparent',
              border: 'none',
              cursor: 'pointer',
              fontSize: '16px'
            }}>
              View All Inventories →
            </button>
          </div>
        </div>

        {/* Client Overview */}
        <div style={{
          backgroundColor: 'white',
          borderRadius: '16px',
          boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1)',
          border: '1px solid #f3f4f6'
        }}>
          <div style={{
            padding: '24px 32px',
            borderBottom: '1px solid #e5e7eb'
          }}>
            <h2 style={{
              fontSize: '24px',
              fontWeight: 'bold',
              color: '#111827',
              margin: '0 0 4px 0'
            }}>
              Client Overview
            </h2>
            <p style={{
              color: '#6b7280',
              margin: 0
            }}>
              Manage your property owners
            </p>
          </div>
          <div style={{ padding: '24px' }}>
            {clients.length === 0 ? (
              <div style={{
                textAlign: 'center',
                padding: '40px',
                color: '#6b7280'
              }}>
                <p>No clients found. Sample data will be created automatically.</p>
              </div>
            ) : (
              <div style={{
                display: 'flex',
                flexDirection: 'column',
                gap: '16px'
              }}>
                {clients.map((client) => {
                  const clientInventories = inventories.filter(inv => inv.clientId === client.id)
                  const completedCount = clientInventories.filter(inv => inv.status === 'completed').length
                  const totalCount = clientInventories.length

                  return (
                    <div key={client.id} style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '16px',
                      backgroundColor: '#f9fafb',
                      borderRadius: '12px'
                    }}>
                      <div style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '16px'
                      }}>
                        <div style={{
                          width: '40px',
                          height: '40px',
                          backgroundColor: '#e0e7ff',
                          borderRadius: '50%',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center'
                        }}>
                          <span style={{
                            color: '#7c3aed',
                            fontWeight: 'bold',
                            fontSize: '14px'
                          }}>
                            {client.name.split(' ').map(n => n[0]).join('')}
                          </span>
                        </div>
                        <div>
                          <p style={{
                            fontWeight: '600',
                            color: '#111827',
                            margin: '0 0 2px 0',
                            fontSize: '16px'
                          }}>
                            {client.name}
                          </p>
                          <p style={{
                            fontSize: '14px',
                            color: '#6b7280',
                            margin: 0
                          }}>
                            {client.email}
                          </p>
                        </div>
                      </div>
                      <div style={{ textAlign: 'right' }}>
                        <p style={{
                          fontWeight: '600',
                          color: '#111827',
                          margin: '0 0 2px 0',
                          fontSize: '14px'
                        }}>
                          {totalCount} Properties
                        </p>
                        <p style={{
                          fontSize: '12px',
                          color: totalCount > 0 ? '#10b981' : '#6b7280',
                          margin: 0
                        }}>
                          {totalCount > 0 ? `${completedCount}/${totalCount} completed` : 'No inventories'}
                        </p>
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}