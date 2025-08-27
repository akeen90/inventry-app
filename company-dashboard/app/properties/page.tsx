'use client'

import Link from 'next/link'
import { useState } from 'react'

interface Property {
  id: string
  name: string
  address: string
  type: 'house' | 'flat' | 'maisonette' | 'bungalow'
  status: 'active' | 'pending' | 'completed'
  inventoryType: 'check_in' | 'check_out' | 'mid_term' | 'maintenance'
  landlordName: string
  tenantName?: string
  completionPercentage: number
  totalRooms: number
  completedRooms: number
  totalItems: number
  completedItems: number
  lastUpdated: string
}

export default function Properties() {
  const [properties] = useState<Property[]>([
    {
      id: '1',
      name: 'Victorian Terrace',
      address: '12 Baker Street, London SW1A 1AA',
      type: 'house',
      status: 'active',
      inventoryType: 'check_in',
      landlordName: 'Smith Property Ltd',
      tenantName: 'John Williams',
      completionPercentage: 75,
      totalRooms: 4,
      completedRooms: 3,
      totalItems: 32,
      completedItems: 24,
      lastUpdated: '2 hours ago'
    },
    {
      id: '2',
      name: 'City Centre Flat',
      address: '45 Manchester Road, Birmingham B1 1AA',
      type: 'flat',
      status: 'pending',
      inventoryType: 'check_out',
      landlordName: 'Smith Property Ltd',
      tenantName: 'Sarah Johnson',
      completionPercentage: 45,
      totalRooms: 2,
      completedRooms: 1,
      totalItems: 18,
      completedItems: 8,
      lastUpdated: '1 day ago'
    },
    {
      id: '3',
      name: 'Countryside Cottage',
      address: 'Oak Lane, Cotswolds, Gloucestershire GL54 1AA',
      type: 'house',
      status: 'completed',
      inventoryType: 'mid_term',
      landlordName: 'Smith Property Ltd',
      completionPercentage: 100,
      totalRooms: 3,
      completedRooms: 3,
      totalItems: 26,
      completedItems: 26,
      lastUpdated: '3 days ago'
    },
    {
      id: '4',
      name: 'Modern Studio',
      address: '89 High Street, Manchester M1 2AA',
      type: 'flat',
      status: 'active',
      inventoryType: 'check_in',
      landlordName: 'City Living Ltd',
      tenantName: 'Emma Davis',
      completionPercentage: 20,
      totalRooms: 1,
      completedRooms: 0,
      totalItems: 12,
      completedItems: 2,
      lastUpdated: '5 hours ago'
    }
  ])

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-blue-100 text-blue-800'
      case 'pending': return 'bg-orange-100 text-orange-800'
      case 'completed': return 'bg-green-100 text-green-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getInventoryTypeDisplay = (type: string) => {
    switch (type) {
      case 'check_in': return 'Check-in'
      case 'check_out': return 'Check-out'
      case 'mid_term': return 'Mid-term'
      case 'maintenance': return 'Maintenance'
      default: return type
    }
  }

  const getProgressColor = (percentage: number) => {
    if (percentage >= 80) return 'text-green-600'
    if (percentage >= 50) return 'text-orange-600'
    return 'text-red-600'
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Properties</h1>
          <p className="text-gray-500">Manage property inventories and track progress</p>
        </div>
        <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
          Add Property
        </button>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-blue-100 rounded-lg">
              <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-6m-8 0H3m2 0h6M9 7h6m-6 4h6m-6 4h6m-6 4h6" />
              </svg>
            </div>
            <div className="ml-4">
              <p className="text-sm text-gray-500">Total Properties</p>
              <p className="text-2xl font-bold text-gray-900">{properties.length}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-orange-100 rounded-lg">
              <svg className="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div className="ml-4">
              <p className="text-sm text-gray-500">In Progress</p>
              <p className="text-2xl font-bold text-gray-900">
                {properties.filter(p => p.status === 'active' || p.status === 'pending').length}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-green-100 rounded-lg">
              <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div className="ml-4">
              <p className="text-sm text-gray-500">Completed</p>
              <p className="text-2xl font-bold text-gray-900">
                {properties.filter(p => p.status === 'completed').length}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex items-center">
            <div className="p-2 bg-purple-100 rounded-lg">
              <svg className="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
              </svg>
            </div>
            <div className="ml-4">
              <p className="text-sm text-gray-500">Avg. Completion</p>
              <p className="text-2xl font-bold text-gray-900">
                {Math.round(properties.reduce((acc, p) => acc + p.completionPercentage, 0) / properties.length)}%
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Properties Table */}
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-medium text-gray-900">All Properties</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Property
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Progress
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Rooms/Items
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Last Updated
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {properties.map((property) => (
                <tr key={property.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <div>
                      <div className="font-medium text-gray-900">{property.name}</div>
                      <div className="text-sm text-gray-500">{property.address}</div>
                      <div className="text-xs text-gray-400">
                        Landlord: {property.landlordName}
                        {property.tenantName && ` • Tenant: ${property.tenantName}`}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="px-2 py-1 text-xs font-medium bg-gray-100 text-gray-800 rounded">
                      {getInventoryTypeDisplay(property.inventoryType)}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor(property.status)}`}>
                      {property.status.charAt(0).toUpperCase() + property.status.slice(1)}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center">
                      <div className="w-16 bg-gray-200 rounded-full h-2 mr-3">
                        <div 
                          className="bg-blue-600 h-2 rounded-full" 
                          style={{ width: `${property.completionPercentage}%` }}
                        ></div>
                      </div>
                      <span className={`text-sm font-medium ${getProgressColor(property.completionPercentage)}`}>
                        {property.completionPercentage}%
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900">
                      <div>Rooms: {property.completedRooms}/{property.totalRooms}</div>
                      <div>Items: {property.completedItems}/{property.totalItems}</div>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-500">
                    {property.lastUpdated}
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex space-x-2">
                      <Link 
                        href={`/properties/${property.id}`}
                        className="text-blue-600 hover:text-blue-900 text-sm font-medium"
                      >
                        View Details
                      </Link>
                      <button className="text-gray-400 hover:text-gray-600 text-sm">
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                        </svg>
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}