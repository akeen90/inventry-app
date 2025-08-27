'use client'

export default function Dashboard() {
  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-800 rounded-2xl p-8 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold mb-2">Property Inventory Dashboard</h1>
            <p className="text-blue-100 text-lg">Manage lettings inventories and track progress across your portfolio</p>
          </div>
          <div className="hidden lg:block">
            <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4">
              <div className="text-2xl font-bold">£2.4M</div>
              <div className="text-blue-100 text-sm">Portfolio Value</div>
            </div>
          </div>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-gradient-to-br from-blue-50 to-blue-100 p-6 rounded-xl border border-blue-200 hover:shadow-lg transition-all duration-300">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-blue-600 text-sm font-medium uppercase tracking-wide">Total Properties</p>
              <p className="text-3xl font-bold text-blue-900 mt-2">4</p>
              <p className="text-blue-600 text-sm mt-1">Active portfolio</p>
            </div>
            <div className="bg-blue-500 p-3 rounded-xl shadow-lg">
              <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-6m-8 0H3m2 0h6M9 7h6m-6 4h6m-6 4h6m-6 4h6" />
              </svg>
            </div>
          </div>
        </div>

        <div className="bg-gradient-to-br from-orange-50 to-orange-100 p-6 rounded-xl border border-orange-200 hover:shadow-lg transition-all duration-300">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-orange-600 text-sm font-medium uppercase tracking-wide">In Progress</p>
              <p className="text-3xl font-bold text-orange-900 mt-2">3</p>
              <p className="text-orange-600 text-sm mt-1">Active inventories</p>
            </div>
            <div className="bg-orange-500 p-3 rounded-xl shadow-lg">
              <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
          </div>
        </div>

        <div className="bg-gradient-to-br from-green-50 to-green-100 p-6 rounded-xl border border-green-200 hover:shadow-lg transition-all duration-300">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-green-600 text-sm font-medium uppercase tracking-wide">Completed</p>
              <p className="text-3xl font-bold text-green-900 mt-2">1</p>
              <p className="text-green-600 text-sm mt-1">Signed off</p>
            </div>
            <div className="bg-green-500 p-3 rounded-xl shadow-lg">
              <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
          </div>
        </div>

        <div className="bg-gradient-to-br from-purple-50 to-purple-100 p-6 rounded-xl border border-purple-200 hover:shadow-lg transition-all duration-300">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-purple-600 text-sm font-medium uppercase tracking-wide">Avg. Progress</p>
              <p className="text-3xl font-bold text-purple-900 mt-2">55%</p>
              <p className="text-purple-600 text-sm mt-1">Overall completion</p>
            </div>
            <div className="bg-purple-500 p-3 rounded-xl shadow-lg">
              <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
              </svg>
            </div>
          </div>
        </div>
      </div>

      {/* Content Cards */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Properties Overview */}
        <div className="lg:col-span-2 bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden">
          <div className="bg-gradient-to-r from-gray-50 to-gray-100 p-6 border-b">
            <div className="flex justify-between items-center">
              <div>
                <h3 className="text-xl font-bold text-gray-900">Active Properties</h3>
                <p className="text-gray-600 mt-1">Monitor inventory progress across your portfolio</p>
              </div>
              <a href="/properties" className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors">
                View All
              </a>
            </div>
          </div>
          <div className="p-6 space-y-4">
            <a href="/properties/1" className="block group">
              <div className="bg-gradient-to-r from-blue-50 to-indigo-50 p-5 rounded-xl border border-blue-100 group-hover:border-blue-300 group-hover:shadow-lg transition-all duration-300">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center">
                      <span className="text-white font-bold text-sm">VT</span>
                    </div>
                    <div>
                      <h4 className="font-bold text-gray-900">Victorian Terrace</h4>
                      <p className="text-sm text-gray-600">12 Baker Street, London</p>
                    </div>
                  </div>
                  <span className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-xs font-medium">Check-in</span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <div className="flex justify-between text-sm mb-1">
                      <span className="text-gray-600">Progress</span>
                      <span className="font-medium text-blue-600">75% Complete</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div className="bg-gradient-to-r from-blue-500 to-blue-600 h-2 rounded-full" style={{width: '75%'}}></div>
                    </div>
                    <p className="text-xs text-gray-500 mt-2">3 of 4 rooms completed • 24 items catalogued</p>
                  </div>
                </div>
              </div>
            </a>

            <a href="/properties/2" className="block group">
              <div className="bg-gradient-to-r from-orange-50 to-yellow-50 p-5 rounded-xl border border-orange-100 group-hover:border-orange-300 group-hover:shadow-lg transition-all duration-300">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-orange-500 rounded-lg flex items-center justify-center">
                      <span className="text-white font-bold text-sm">CC</span>
                    </div>
                    <div>
                      <h4 className="font-bold text-gray-900">City Centre Flat</h4>
                      <p className="text-sm text-gray-600">45 Manchester Road, Birmingham</p>
                    </div>
                  </div>
                  <span className="bg-orange-100 text-orange-800 px-3 py-1 rounded-full text-xs font-medium">Check-out</span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <div className="flex justify-between text-sm mb-1">
                      <span className="text-gray-600">Progress</span>
                      <span className="font-medium text-orange-600">45% Complete</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div className="bg-gradient-to-r from-orange-500 to-orange-600 h-2 rounded-full" style={{width: '45%'}}></div>
                    </div>
                    <p className="text-xs text-gray-500 mt-2">1 of 2 rooms completed • 8 items catalogued</p>
                  </div>
                </div>
              </div>
            </a>

            <a href="/properties/3" className="block group">
              <div className="bg-gradient-to-r from-green-50 to-emerald-50 p-5 rounded-xl border border-green-100 group-hover:border-green-300 group-hover:shadow-lg transition-all duration-300">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-green-500 rounded-lg flex items-center justify-center">
                      <span className="text-white font-bold text-sm">CC</span>
                    </div>
                    <div>
                      <h4 className="font-bold text-gray-900">Countryside Cottage</h4>
                      <p className="text-sm text-gray-600">Oak Lane, Cotswolds</p>
                    </div>
                  </div>
                  <span className="bg-green-100 text-green-800 px-3 py-1 rounded-full text-xs font-medium">Complete ✓</span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <div className="flex justify-between text-sm mb-1">
                      <span className="text-gray-600">Progress</span>
                      <span className="font-medium text-green-600">100% Complete</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div className="bg-gradient-to-r from-green-500 to-green-600 h-2 rounded-full" style={{width: '100%'}}></div>
                    </div>
                    <p className="text-xs text-gray-500 mt-2">3 of 3 rooms completed • Signed off by all parties</p>
                  </div>
                </div>
              </div>
            </a>
          </div>
        </div>

        {/* Activity Feed */}
        <div className="bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden">
          <div className="bg-gradient-to-r from-gray-50 to-gray-100 p-6 border-b">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-xl font-bold text-gray-900">Live Activity</h3>
                <p className="text-gray-600 mt-1">Real-time updates</p>
              </div>
              <div className="flex items-center space-x-2">
                <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                <span className="text-xs text-gray-500">Live</span>
              </div>
            </div>
          </div>
          <div className="p-6 space-y-4 max-h-96 overflow-y-auto">
            <div className="flex items-start space-x-4 p-3 bg-blue-50 rounded-xl border border-blue-100">
              <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0">
                <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900">Kitchen inventory completed</p>
                <p className="text-xs text-gray-600 mt-1">Victorian Terrace • All appliances catalogued</p>
                <p className="text-xs text-blue-600 mt-1 font-medium">2 hours ago</p>
              </div>
            </div>

            <div className="flex items-start space-x-4 p-3 bg-green-50 rounded-xl border border-green-100">
              <div className="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0">
                <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900">Landlord signature received</p>
                <p className="text-xs text-gray-600 mt-1">Countryside Cottage • Inventory signed off</p>
                <p className="text-xs text-green-600 mt-1 font-medium">4 hours ago</p>
              </div>
            </div>

            <div className="flex items-start space-x-4 p-3 bg-orange-50 rounded-xl border border-orange-100">
              <div className="w-8 h-8 bg-orange-500 rounded-full flex items-center justify-center flex-shrink-0">
                <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                </svg>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900">New check-in started</p>
                <p className="text-xs text-gray-600 mt-1">Modern Studio • Tenant: Emma Davis</p>
                <p className="text-xs text-orange-600 mt-1 font-medium">6 hours ago</p>
              </div>
            </div>

            <div className="flex items-start space-x-4 p-3 bg-purple-50 rounded-xl border border-purple-100">
              <div className="w-8 h-8 bg-purple-500 rounded-full flex items-center justify-center flex-shrink-0">
                <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900">Room added to inventory</p>
                <p className="text-xs text-gray-600 mt-1">City Centre Flat • Master Bedroom</p>
                <p className="text-xs text-purple-600 mt-1 font-medium">1 day ago</p>
              </div>
            </div>

            <div className="flex items-start space-x-4 p-3 bg-red-50 rounded-xl border border-red-100">
              <div className="w-8 h-8 bg-red-500 rounded-full flex items-center justify-center flex-shrink-0">
                <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.854-.833-2.5 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
                </svg>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900">Item condition updated</p>
                <p className="text-xs text-gray-600 mt-1">Coffee Table marked as damaged</p>
                <p className="text-xs text-red-600 mt-1 font-medium">2 days ago</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}