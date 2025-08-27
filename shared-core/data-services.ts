import { 
  collection, 
  doc, 
  getDocs, 
  getDoc, 
  addDoc, 
  updateDoc, 
  deleteDoc,
  query,
  where,
  orderBy,
  onSnapshot,
  Timestamp,
  type Firestore
} from 'firebase/firestore'
import { type User } from 'firebase/auth'

// Data Types
export interface PropertyInventory {
  id: string
  propertyId: string
  clientId: string
  type: 'check-in' | 'check-out' | 'mid-term' | 'maintenance' | 'renewal'
  status: 'scheduled' | 'in-progress' | 'completed'
  progress: number // 0-100
  scheduledDate?: Date
  startDate?: Date
  completedDate?: Date
  rooms: Room[]
  photos: string[]
  notes: string
  createdAt: Date
  updatedAt: Date
}

export interface Property {
  id: string
  clientId: string
  name: string
  address: string
  type: string
  createdAt: Date
  updatedAt: Date
}

export interface Client {
  id: string
  name: string
  email: string
  phone?: string
  properties: string[] // property IDs
  createdAt: Date
  updatedAt: Date
}

export interface Room {
  id: string
  name: string
  items: InventoryItem[]
  completionPercentage: number
}

export interface InventoryItem {
  id: string
  name: string
  condition: 'excellent' | 'good' | 'fair' | 'poor' | 'damaged'
  notes?: string
  photos: string[]
}

// Data Services Class
export class InventryDataService {
  private db: Firestore

  constructor(db: Firestore) {
    this.db = db
  }

  // Client Data Services (for client dashboard - only their data)
  async getClientProperties(clientId: string): Promise<Property[]> {
    try {
      const q = query(
        collection(this.db, 'properties'),
        where('clientId', '==', clientId),
        orderBy('updatedAt', 'desc')
      )
      const querySnapshot = await getDocs(q)
      return querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate(),
        updatedAt: doc.data().updatedAt?.toDate()
      } as Property))
    } catch (error) {
      console.error('Error fetching client properties:', error)
      return []
    }
  }

  async getClientInventories(clientId: string): Promise<PropertyInventory[]> {
    try {
      const q = query(
        collection(this.db, 'inventories'),
        where('clientId', '==', clientId),
        orderBy('updatedAt', 'desc')
      )
      const querySnapshot = await getDocs(q)
      return querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        scheduledDate: doc.data().scheduledDate?.toDate(),
        startDate: doc.data().startDate?.toDate(),
        completedDate: doc.data().completedDate?.toDate(),
        createdAt: doc.data().createdAt?.toDate(),
        updatedAt: doc.data().updatedAt?.toDate()
      } as PropertyInventory))
    } catch (error) {
      console.error('Error fetching client inventories:', error)
      return []
    }
  }

  async getClientStats(clientId: string): Promise<{
    totalProperties: number
    inProgress: number
    completed: number
  }> {
    try {
      const inventories = await this.getClientInventories(clientId)
      return {
        totalProperties: inventories.length,
        inProgress: inventories.filter(inv => inv.status === 'in-progress').length,
        completed: inventories.filter(inv => inv.status === 'completed').length
      }
    } catch (error) {
      console.error('Error fetching client stats:', error)
      return { totalProperties: 0, inProgress: 0, completed: 0 }
    }
  }

  // Company Data Services (for company dashboard - all data)
  async getAllProperties(): Promise<Property[]> {
    try {
      const q = query(
        collection(this.db, 'properties'),
        orderBy('updatedAt', 'desc')
      )
      const querySnapshot = await getDocs(q)
      return querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate(),
        updatedAt: doc.data().updatedAt?.toDate()
      } as Property))
    } catch (error) {
      console.error('Error fetching all properties:', error)
      return []
    }
  }

  async getAllInventories(): Promise<PropertyInventory[]> {
    try {
      const q = query(
        collection(this.db, 'inventories'),
        orderBy('updatedAt', 'desc')
      )
      const querySnapshot = await getDocs(q)
      return querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        scheduledDate: doc.data().scheduledDate?.toDate(),
        startDate: doc.data().startDate?.toDate(),
        completedDate: doc.data().completedDate?.toDate(),
        createdAt: doc.data().createdAt?.toDate(),
        updatedAt: doc.data().updatedAt?.toDate()
      } as PropertyInventory))
    } catch (error) {
      console.error('Error fetching all inventories:', error)
      return []
    }
  }

  async getAllClients(): Promise<Client[]> {
    try {
      const q = query(
        collection(this.db, 'clients'),
        orderBy('updatedAt', 'desc')
      )
      const querySnapshot = await getDocs(q)
      return querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate(),
        updatedAt: doc.data().updatedAt?.toDate()
      } as Client))
    } catch (error) {
      console.error('Error fetching all clients:', error)
      return []
    }
  }

  async getCompanyStats(): Promise<{
    totalProperties: number
    totalClients: number
    inProgress: number
    completed: number
    completionRate: number
  }> {
    try {
      const [properties, clients, inventories] = await Promise.all([
        this.getAllProperties(),
        this.getAllClients(),
        this.getAllInventories()
      ])

      const completed = inventories.filter(inv => inv.status === 'completed').length
      const inProgress = inventories.filter(inv => inv.status === 'in-progress').length
      const total = inventories.length

      return {
        totalProperties: properties.length,
        totalClients: clients.length,
        inProgress,
        completed,
        completionRate: total > 0 ? Math.round((completed / total) * 100) : 0
      }
    } catch (error) {
      console.error('Error fetching company stats:', error)
      return { 
        totalProperties: 0, 
        totalClients: 0, 
        inProgress: 0, 
        completed: 0, 
        completionRate: 0 
      }
    }
  }

  // Shared CRUD Operations
  async createInventory(inventory: Omit<PropertyInventory, 'id' | 'createdAt' | 'updatedAt'>): Promise<string | null> {
    try {
      const now = Timestamp.now()
      const docRef = await addDoc(collection(this.db, 'inventories'), {
        ...inventory,
        createdAt: now,
        updatedAt: now
      })
      return docRef.id
    } catch (error) {
      console.error('Error creating inventory:', error)
      return null
    }
  }

  async updateInventory(id: string, updates: Partial<PropertyInventory>): Promise<boolean> {
    try {
      const docRef = doc(this.db, 'inventories', id)
      await updateDoc(docRef, {
        ...updates,
        updatedAt: Timestamp.now()
      })
      return true
    } catch (error) {
      console.error('Error updating inventory:', error)
      return false
    }
  }

  async deleteInventory(id: string): Promise<boolean> {
    try {
      await deleteDoc(doc(this.db, 'inventories', id))
      return true
    } catch (error) {
      console.error('Error deleting inventory:', error)
      return false
    }
  }

  async createProperty(property: Omit<Property, 'id' | 'createdAt' | 'updatedAt'>): Promise<string | null> {
    try {
      const now = Timestamp.now()
      const docRef = await addDoc(collection(this.db, 'properties'), {
        ...property,
        createdAt: now,
        updatedAt: now
      })
      return docRef.id
    } catch (error) {
      console.error('Error creating property:', error)
      return null
    }
  }

  async createClient(client: Omit<Client, 'id' | 'createdAt' | 'updatedAt'>): Promise<string | null> {
    try {
      const now = Timestamp.now()
      const docRef = await addDoc(collection(this.db, 'clients'), {
        ...client,
        createdAt: now,
        updatedAt: now
      })
      return docRef.id
    } catch (error) {
      console.error('Error creating client:', error)
      return null
    }
  }

  // Real-time listeners for live updates
  subscribeToClientInventories(clientId: string, callback: (inventories: PropertyInventory[]) => void): () => void {
    const q = query(
      collection(this.db, 'inventories'),
      where('clientId', '==', clientId),
      orderBy('updatedAt', 'desc')
    )
    
    return onSnapshot(q, (querySnapshot) => {
      const inventories = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        scheduledDate: doc.data().scheduledDate?.toDate(),
        startDate: doc.data().startDate?.toDate(),
        completedDate: doc.data().completedDate?.toDate(),
        createdAt: doc.data().createdAt?.toDate(),
        updatedAt: doc.data().updatedAt?.toDate()
      } as PropertyInventory))
      callback(inventories)
    })
  }

  subscribeToAllInventories(callback: (inventories: PropertyInventory[]) => void): () => void {
    const q = query(
      collection(this.db, 'inventories'),
      orderBy('updatedAt', 'desc')
    )
    
    return onSnapshot(q, (querySnapshot) => {
      const inventories = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        scheduledDate: doc.data().scheduledDate?.toDate(),
        startDate: doc.data().startDate?.toDate(),
        completedDate: doc.data().completedDate?.toDate(),
        createdAt: doc.data().createdAt?.toDate(),
        updatedAt: doc.data().updatedAt?.toDate()
      } as PropertyInventory))
      callback(inventories)
    })
  }
}

// Sample data seeding function for development
export async function seedSampleData(dataService: InventryDataService) {
  try {
    console.log('Seeding sample data...')

    // Create sample clients
    const johnClientId = await dataService.createClient({
      name: 'John Smith',
      email: 'john.smith@example.com',
      phone: '+1 (555) 123-4567',
      properties: []
    })

    const sarahClientId = await dataService.createClient({
      name: 'Sarah Johnson',
      email: 'sarah.johnson@example.com',
      phone: '+1 (555) 987-6543',
      properties: []
    })

    if (!johnClientId || !sarahClientId) {
      throw new Error('Failed to create clients')
    }

    // Create sample properties
    const properties = [
      {
        clientId: johnClientId,
        name: 'Victorian Terrace',
        address: '12 Baker Street, London',
        type: 'Residential'
      },
      {
        clientId: johnClientId,
        name: 'City Centre Flat',
        address: '45 Manchester Road, Birmingham',
        type: 'Residential'
      },
      {
        clientId: johnClientId,
        name: 'Mountain Cabin',
        address: '789 Pine Road, Aspen CO',
        type: 'Vacation Rental'
      },
      {
        clientId: sarahClientId,
        name: 'Downtown Office',
        address: '123 Business District, New York',
        type: 'Commercial'
      },
      {
        clientId: sarahClientId,
        name: 'Beachfront Villa',
        address: '456 Ocean Drive, Miami FL',
        type: 'Luxury'
      }
    ]

    const propertyIds = await Promise.all(
      properties.map(property => dataService.createProperty(property))
    )

    // Create sample inventories
    const sampleRooms: Room[] = [
      {
        id: '1',
        name: 'Living Room',
        completionPercentage: 100,
        items: [
          {
            id: '1',
            name: 'Sofa',
            condition: 'good',
            notes: 'Minor wear on cushions',
            photos: []
          },
          {
            id: '2',
            name: 'Coffee Table',
            condition: 'excellent',
            photos: []
          }
        ]
      },
      {
        id: '2',
        name: 'Kitchen',
        completionPercentage: 75,
        items: [
          {
            id: '3',
            name: 'Refrigerator',
            condition: 'good',
            photos: []
          }
        ]
      }
    ]

    const inventories = [
      {
        propertyId: propertyIds[0]!,
        clientId: johnClientId,
        type: 'check-out' as const,
        status: 'completed' as const,
        progress: 100,
        rooms: sampleRooms,
        photos: [],
        notes: 'Property in excellent condition',
        completedDate: new Date('2023-11-15')
      },
      {
        propertyId: propertyIds[1]!,
        clientId: johnClientId,
        type: 'mid-term' as const,
        status: 'in-progress' as const,
        progress: 75,
        rooms: sampleRooms.map(room => ({ ...room, completionPercentage: 75 })),
        photos: [],
        notes: 'Inspection in progress',
        startDate: new Date('2023-12-01')
      },
      {
        propertyId: propertyIds[2]!,
        clientId: johnClientId,
        type: 'check-in' as const,
        status: 'scheduled' as const,
        progress: 0,
        rooms: [],
        photos: [],
        notes: 'Scheduled for next week',
        scheduledDate: new Date('2023-12-10')
      }
    ]

    await Promise.all(
      inventories.map(inventory => dataService.createInventory(inventory))
    )

    console.log('Sample data seeded successfully!')
  } catch (error) {
    console.error('Error seeding sample data:', error)
  }
}