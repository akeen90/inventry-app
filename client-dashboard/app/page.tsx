'use client'

export default function ClientDashboard() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Inventry</h1>
              <p className="text-gray-600">Client Portal</p>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-gray-700">Welcome, John Smith</span>
              <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                Sign Out
              </button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          <div className="mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-2">Your Properties</h2>
            <p className="text-gray-600">View and download inventory reports for your properties</p>
          </div>

          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-6">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-medium text-gray-900">Victorian Terrace</h3>
                  <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                    Completed
                  </span>
                </div>
                <p className="mt-2 text-sm text-gray-600">12 Baker Street, London SW1A 1AA</p>
                <div className="mt-4">
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <span className="text-gray-500">Rooms:</span>
                      <span className="ml-1 font-medium">8</span>
                    </div>
                    <div>
                      <span className="text-gray-500">Items:</span>
                      <span className="ml-1 font-medium">156</span>
                    </div>
                    <div>
                      <span className="text-gray-500">Photos:</span>
                      <span className="ml-1 font-medium">87</span>
                    </div>
                    <div>
                      <span className="text-gray-500">Completed:</span>
                      <span className="ml-1 font-medium">15 Nov</span>
                    </div>
                  </div>
                </div>
                <div className="mt-6 flex space-x-3">
                  <button className="flex-1 bg-blue-600 text-white px-3 py-2 rounded text-sm hover:bg-blue-700">
                    View Report
                  </button>
                  <button className="flex-1 bg-gray-200 text-gray-700 px-3 py-2 rounded text-sm hover:bg-gray-300">
                    Download PDF
                  </button>
                </div>
              </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-6">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-medium text-gray-900">City Centre Flat</h3>
                  <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                    In Progress
                  </span>
                </div>
                <p className="mt-2 text-sm text-gray-600">45 Manchester Road, Birmingham B1 1AA</p>
                <div className="mt-4">
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <span className="text-gray-500">Rooms:</span>
                      <span className="ml-1 font-medium">4</span>
                    </div>
                    <div>
                      <span className="text-gray-500">Items:</span>
                      <span className="ml-1 font-medium">67</span>
                    </div>
                    <div>
                      <span className="text-gray-500">Progress:</span>
                      <span className="ml-1 font-medium">75%</span>
                    </div>
                    <div>
                      <span className="text-gray-500">Est. Completion:</span>
                      <span className="ml-1 font-medium">Dec 1</span>
                    </div>
                  </div>
                </div>
                <div className="mt-4">
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div className="bg-blue-600 h-2 rounded-full" style={{width: '75%'}}></div>
                  </div>
                </div>
                <div className="mt-6 flex space-x-3">
                  <button className="flex-1 bg-gray-400 text-white px-3 py-2 rounded text-sm cursor-not-allowed">
                    View Report
                  </button>
                  <button className="flex-1 bg-blue-600 text-white px-3 py-2 rounded text-sm hover:bg-blue-700">
                    View Progress
                  </button>
                </div>
              </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-6">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-medium text-gray-900">Mountain Cabin</h3>
                  <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                    Scheduled
                  </span>
                </div>
                <p className="mt-2 text-sm text-gray-600">789 Pine Road, Aspen CO</p>
                <div className="mt-4">
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <span className="text-gray-500">Scheduled:</span>
                      <span className="ml-1 font-medium">Dec 10</span>
                    </div>
                    <div>
                      <span className="text-gray-500">Inspector:</span>
                      <span className="ml-1 font-medium">Sarah J.</span>
                    </div>
                    <div>
                      <span className="text-gray-500">Type:</span>
                      <span className="ml-1 font-medium">Cabin</span>
                    </div>
                    <div>
                      <span className="text-gray-500">Est. Duration:</span>
                      <span className="ml-1 font-medium">2 days</span>
                    </div>
                  </div>
                </div>
                <div className="mt-6 flex space-x-3">
                  <button className="flex-1 bg-gray-200 text-gray-700 px-3 py-2 rounded text-sm hover:bg-gray-300">
                    Contact Inspector
                  </button>
                  <button className="flex-1 bg-gray-200 text-gray-700 px-3 py-2 rounded text-sm hover:bg-gray-300">
                    Reschedule
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div className="mt-12">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Recent Activity</h2>
            <div className="bg-white shadow overflow-hidden sm:rounded-lg">
              <ul className="divide-y divide-gray-200">
                <li className="px-6 py-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-2 w-2 bg-green-400 rounded-full"></div>
                      <div className="ml-4">
                        <p className="text-sm font-medium text-gray-900">Report completed for Sunset Villa</p>
                        <p className="text-sm text-gray-500">November 15, 2023</p>
                      </div>
                    </div>
                    <button className="text-blue-600 text-sm hover:text-blue-800">View</button>
                  </div>
                </li>
                <li className="px-6 py-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-2 w-2 bg-blue-400 rounded-full"></div>
                      <div className="ml-4">
                        <p className="text-sm font-medium text-gray-900">Inspection started for Downtown Apartment</p>
                        <p className="text-sm text-gray-500">November 12, 2023</p>
                      </div>
                    </div>
                    <button className="text-blue-600 text-sm hover:text-blue-800">View Progress</button>
                  </div>
                </li>
                <li className="px-6 py-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center">
                      <div className="flex-shrink-0 h-2 w-2 bg-yellow-400 rounded-full"></div>
                      <div className="ml-4">
                        <p className="text-sm font-medium text-gray-900">Inspection scheduled for Mountain Cabin</p>
                        <p className="text-sm text-gray-500">November 8, 2023</p>
                      </div>
                    </div>
                    <button className="text-blue-600 text-sm hover:text-blue-800">Details</button>
                  </div>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}