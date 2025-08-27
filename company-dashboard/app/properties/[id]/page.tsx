'use client'

import { useState } from 'react'
import Link from 'next/link'

interface InventoryItem {
  id: string
  name: string
  category: string
  condition: 'excellent' | 'good' | 'fair' | 'poor' | 'damaged' | 'missing'
  description?: string
  photos: string[]
  notes?: string
  isComplete: boolean
}

interface Room {
  id: string
  name: string
  type: string
  items: InventoryItem[]
  notes?: string
  completionPercentage: number
}

interface Property {
  id: string
  name: string
  address: string
  type: string
  status: string
  inventoryType: string
  landlordName: string
  tenantName?: string
  completionPercentage: number
  rooms: Room[]
  signatures: {
    landlord?: boolean
    tenant?: boolean
  }
}

export default function PropertyDetail({ params }: { params: { id: string } }) {
  const [property] = useState<Property>({
    id: params.id,
    name: 'Victorian Terrace',
    address: '12 Baker Street, London SW1A 1AA',
    type: 'house',
    status: 'active',
    inventoryType: 'check_in',
    landlordName: 'Smith Property Ltd',
    tenantName: 'John Williams',
    completionPercentage: 75,
    signatures: {
      landlord: false,
      tenant: false
    },
    rooms: [
      {
        id: '1',
        name: 'Living Room',
        type: 'living_room',
        completionPercentage: 100,
        items: [
          {
            id: '1',
            name: '3-Seater Sofa',
            category: 'furniture',
            condition: 'good',
            description: 'Grey fabric 3-seater sofa',
            photos: [],
            isComplete: true
          },
          {
            id: '2',
            name: 'Coffee Table',
            category: 'furniture',
            condition: 'fair',
            description: 'Wooden coffee table with minor scratches',
            photos: [],
            isComplete: true
          },
          {
            id: '3',
            name: 'TV Stand',
            category: 'furniture',
            condition: 'good',
            photos: [],
            isComplete: true
          },
          {
            id: '4',
            name: 'Carpet',
            category: 'flooring',
            condition: 'good',
            description: 'Beige carpet covering entire floor',
            photos: [],
            isComplete: true
          }
        ]
      },
      {
        id: '2',
        name: 'Kitchen',
        type: 'kitchen',
        completionPercentage: 75,
        items: [
          {
            id: '5',
            name: 'Refrigerator',
            category: 'appliances',
            condition: 'good',
            description: 'White fridge-freezer, working condition',
            photos: [],
            isComplete: true
          },
          {
            id: '6',
            name: 'Oven',
            category: 'appliances',
            condition: 'excellent',
            description: 'Electric oven with grill, recently serviced',
            photos: [],
            isComplete: true
          },
          {
            id: '7',
            name: 'Kitchen Cabinets',
            category: 'fixtures',
            condition: 'good',
            description: 'White kitchen units with handles',
            photos: [],
            isComplete: true
          },
          {
            id: '8',
            name: 'Worktop',
            category: 'fixtures',
            condition: 'fair',
            description: 'Laminate worktop with some wear marks',
            photos: [],
            isComplete: false
          }
        ]
      },
      {
        id: '3',
        name: 'Master Bedroom',
        type: 'bedroom',
        completionPercentage: 50,
        items: [
          {
            id: '9',
            name: 'Double Bed Frame',
            category: 'furniture',
            condition: 'good',
            photos: [],
            isComplete: true
          },
          {
            id: '10',
            name: 'Wardrobe',
            category: 'furniture',
            condition: 'excellent',
            description: 'Built-in wardrobe with sliding doors',
            photos: [],
            isComplete: true
          },
          {
            id: '11',
            name: 'Carpet',
            category: 'flooring',
            condition: 'good',
            photos: [],
            isComplete: false
          },
          {
            id: '12',
            name: 'Curtains',
            category: 'fixtures',
            condition: 'fair',
            photos: [],
            isComplete: false
          }
        ]
      }
    ]
  })

  const getConditionColor = (condition: string) => {
    switch (condition) {
      case 'excellent': return 'text-green-600 bg-green-100'
      case 'good': return 'text-blue-600 bg-blue-100'
      case 'fair': return 'text-orange-600 bg-orange-100'
      case 'poor': return 'text-red-600 bg-red-100'
      case 'damaged': return 'text-red-800 bg-red-200'
      case 'missing': return 'text-gray-600 bg-gray-100'
      default: return 'text-gray-600 bg-gray-100'
    }
  }

  const getRoomIcon = (type: string) => {
    switch (type) {
      case 'living_room': return '🛋️'
      case 'kitchen': return '🍽️'
      case 'bedroom': return '🛏️'
      case 'bathroom': return '🚿'
      default: return '🏠'
    }
  }

  const totalItems = property.rooms.reduce((acc, room) => acc + room.items.length, 0)
  const completedItems = property.rooms.reduce((acc, room) => acc + room.items.filter(item => item.isComplete).length, 0)

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <Link 
            href="/properties" 
            className="text-blue-600 hover:text-blue-800"
          >
            ← Back to Properties
          </Link>
        </div>
        <div className="flex space-x-3">
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
            Generate Report
          </button>
          <button className="border border-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-50 transition-colors">
            Export PDF
          </button>
        </div>
      </div>

      {/* Property Info Card */}
      <div className="bg-white rounded-lg shadow p-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="md:col-span-2">
            <h1 className="text-2xl font-bold text-gray-900 mb-2">{property.name}</h1>
            <p className="text-gray-600 mb-4">{property.address}</p>
            
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-gray-500">Property Type:</span>
                <span className="ml-2 font-medium capitalize">{property.type}</span>
              </div>
              <div>
                <span className="text-gray-500">Inventory Type:</span>
                <span className="ml-2 font-medium">
                  {property.inventoryType.replace('_', '-').split('-').map(word => 
                    word.charAt(0).toUpperCase() + word.slice(1)
                  ).join(' ')}
                </span>
              </div>
              <div>
                <span className="text-gray-500">Landlord:</span>
                <span className="ml-2 font-medium">{property.landlordName}</span>
              </div>
              {property.tenantName && (
                <div>
                  <span className="text-gray-500">Tenant:</span>
                  <span className="ml-2 font-medium">{property.tenantName}</span>
                </div>
              )}
            </div>
          </div>

          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="font-medium text-gray-900 mb-3">Progress Overview</h3>
            
            <div className="space-y-3">
              <div>
                <div className="flex justify-between text-sm mb-1">
                  <span>Overall Progress</span>
                  <span className="font-medium">{Math.round(property.completionPercentage)}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className="bg-blue-600 h-2 rounded-full" 
                    style={{ width: `${property.completionPercentage}%` }}
                  ></div>
                </div>
              </div>

              <div className="text-sm space-y-1">
                <div className="flex justify-between">
                  <span>Rooms:</span>
                  <span className="font-medium">{property.rooms.length}</span>
                </div>
                <div className="flex justify-between">
                  <span>Total Items:</span>
                  <span className="font-medium">{totalItems}</span>
                </div>
                <div className="flex justify-between">
                  <span>Completed:</span>
                  <span className="font-medium">{completedItems}</span>
                </div>
              </div>

              <div className="pt-2 border-t">
                <div className="text-sm font-medium text-gray-700 mb-2">Signatures</div>
                <div className="space-y-1 text-xs">
                  <div className="flex items-center">
                    {property.signatures.landlord ? (
                      <span className="text-green-600">✓ Landlord Signed</span>
                    ) : (
                      <span className="text-gray-500">○ Landlord Pending</span>
                    )}
                  </div>
                  <div className="flex items-center">
                    {property.signatures.tenant ? (
                      <span className="text-green-600">✓ Tenant Signed</span>
                    ) : (
                      <span className="text-gray-500">○ Tenant Pending</span>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Rooms */}
      <div className="space-y-6">
        <h2 className="text-xl font-bold text-gray-900">Inventory by Room</h2>
        
        {property.rooms.map((room) => (
          <div key={room.id} className="bg-white rounded-lg shadow">
            <div className="px-6 py-4 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <span className="text-2xl">{getRoomIcon(room.type)}</span>
                  <div>
                    <h3 className="text-lg font-medium text-gray-900">{room.name}</h3>
                    <p className="text-sm text-gray-500">{room.items.length} items</p>
                  </div>
                </div>
                <div className="flex items-center space-x-4">
                  <div className="text-right">
                    <div className="text-sm font-medium text-gray-700">
                      {room.items.filter(item => item.isComplete).length} of {room.items.length} complete
                    </div>
                    <div className="w-24 bg-gray-200 rounded-full h-2 mt-1">
                      <div 
                        className="bg-green-600 h-2 rounded-full" 
                        style={{ width: `${room.completionPercentage}%` }}
                      ></div>
                    </div>
                  </div>
                  <button className="text-blue-600 hover:text-blue-800 text-sm">
                    Add Item
                  </button>
                </div>
              </div>
            </div>

            <div className="p-6">
              <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4">
                {room.items.map((item) => (
                  <div key={item.id} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                    <div className="flex items-start justify-between mb-2">
                      <h4 className="font-medium text-gray-900">{item.name}</h4>
                      <div className="flex items-center">
                        {item.isComplete ? (
                          <span className="text-green-600">✓</span>
                        ) : (
                          <span className="text-gray-400">○</span>
                        )}
                      </div>
                    </div>
                    
                    <div className="space-y-2 text-sm">
                      <div>
                        <span className="text-gray-500">Category:</span>
                        <span className="ml-2 capitalize">{item.category.replace('_', ' ')}</span>
                      </div>
                      
                      <div className="flex items-center">
                        <span className="text-gray-500">Condition:</span>
                        <span className={`ml-2 px-2 py-1 rounded text-xs font-medium capitalize ${getConditionColor(item.condition)}`}>
                          {item.condition}
                        </span>
                      </div>
                      
                      {item.description && (
                        <p className="text-gray-600 text-xs">{item.description}</p>
                      )}
                      
                      {item.photos.length > 0 && (
                        <div className="text-xs text-blue-600">
                          📷 {item.photos.length} photo{item.photos.length !== 1 ? 's' : ''}
                        </div>
                      )}
                      
                      {item.notes && (
                        <p className="text-gray-500 text-xs italic">Note: {item.notes}</p>
                      )}
                    </div>
                    
                    <div className="mt-3 flex justify-end">
                      <button className="text-blue-600 hover:text-blue-800 text-xs">
                        Edit Item
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}