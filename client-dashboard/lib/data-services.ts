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
}

// Sample data seeding function for development
export async function seedSampleData(dataService: InventryDataService) {
  // Sample data will be loaded from company dashboard
  console.log('Client dashboard does not seed data - it will be synced from company dashboard')
}