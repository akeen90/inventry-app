'use client'

import './globals.css'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
        <div className="flex h-screen">
          <aside className="w-72 bg-white shadow-2xl border-r border-gray-200">
            <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-blue-600 to-blue-700">
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center">
                  <span className="text-blue-600 font-bold text-lg">I</span>
                </div>
                <div>
                  <h1 className="text-xl font-bold text-white">Inventry</h1>
                  <p className="text-blue-100 text-sm">Property Management</p>
                </div>
              </div>
            </div>
            
            <nav className="p-6">
              <div className="space-y-2">
                <a href="/" className="flex items-center space-x-3 px-4 py-3 text-blue-700 bg-blue-50 rounded-xl border border-blue-200 font-medium">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2V7zm0 0V5a2 2 0 012-2h6l2 2h6a2 2 0 012 2v2M7 13h10M7 17h4" />
                  </svg>
                  <span>Dashboard</span>
                </a>
                <a href="/properties" className="flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-gray-50 rounded-xl transition-colors duration-200">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-6m-8 0H3m2 0h6M9 7h6m-6 4h6m-6 4h6m-6 4h6" />
                  </svg>
                  <span>Properties</span>
                </a>
                <a href="/clients" className="flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-gray-50 rounded-xl transition-colors duration-200">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                  </svg>
                  <span>Clients</span>
                </a>
                <a href="/reports" className="flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-gray-50 rounded-xl transition-colors duration-200">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                  <span>Reports</span>
                </a>
                <a href="/users" className="flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-gray-50 rounded-xl transition-colors duration-200">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                  </svg>
                  <span>Team</span>
                </a>
                <a href="/settings" className="flex items-center space-x-3 px-4 py-3 text-gray-700 hover:bg-gray-50 rounded-xl transition-colors duration-200">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  <span>Settings</span>
                </a>
              </div>

              <div className="mt-8 pt-6 border-t border-gray-200">
                <div className="bg-gradient-to-r from-blue-50 to-indigo-50 p-4 rounded-xl border border-blue-100">
                  <div className="flex items-center space-x-3">
                    <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                      <span className="text-white text-sm font-bold">A</span>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900">Aaron Keen</p>
                      <p className="text-xs text-gray-500 truncate">Property Manager</p>
                    </div>
                  </div>
                </div>
              </div>
            </nav>
          </aside>

          <main className="flex-1 overflow-auto">
            <header className="bg-white/80 backdrop-blur-sm border-b border-gray-200">
              <div className="px-8 py-6">
                <div className="flex items-center justify-between">
                  <div>
                    <h2 className="text-2xl font-bold text-gray-900">Welcome back, Aaron</h2>
                    <p className="text-gray-600 mt-1">Here's what's happening with your properties today</p>
                  </div>
                  <div className="flex items-center space-x-4">
                    <button className="p-2 text-gray-500 hover:text-gray-700 rounded-lg hover:bg-gray-100 transition-colors">
                      <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 17h5l-5 5-5-5h5zm0 0V3" />
                      </svg>
                    </button>
                    <button className="p-2 text-gray-500 hover:text-gray-700 rounded-lg hover:bg-gray-100 transition-colors relative">
                      <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 17h5l-5 5-5-5h5zm0 0V3" />
                      </svg>
                      <div className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></div>
                    </button>
                  </div>
                </div>
              </div>
            </header>
            
            <div className="p-8">
              {children}
            </div>
          </main>
        </div>
      </body>
    </html>
  )
}