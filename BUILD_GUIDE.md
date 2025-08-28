# Inventry2 - Inventory Management System

A comprehensive inventory management system with separate dashboards for clients and companies.

## Project Structure

```
Inventry2/
├── client-dashboard/     # Client portal for inventory access
├── company-dashboard/    # Company admin dashboard
├── shared/              # Shared utilities and components
├── shared-core/         # Core shared functionality
├── docs/               # Documentation
└── ios-app/            # iOS application
```

## Prerequisites

- Node.js >= 18.0.0
- npm >= 8.0.0
- Firebase CLI (for deployment)

## Setup

### 1. Install Dependencies

From the root directory:

```bash
npm install
npm run install:all
```

### 2. Environment Configuration

#### For Company Dashboard:
1. Copy `.env.local.example` to `.env.local` in the `company-dashboard` directory
2. Add your Firebase Admin SDK credentials

```bash
cd company-dashboard
cp .env.local.example .env.local
# Edit .env.local with your Firebase credentials
```

#### For Client Dashboard:
Create a `.env.local` file if needed for any environment-specific configurations.

## Development

### Run both dashboards simultaneously:
```bash
npm run dev
```

### Run individual dashboards:
```bash
npm run dev:client   # Client dashboard on http://localhost:3002
npm run dev:company  # Company dashboard on http://localhost:3001
```

## Building for Production

### Build all projects:
```bash
npm run build
# or
./build-all.sh
```

### Build individual projects:
```bash
npm run build:client   # Build client dashboard
npm run build:company  # Build company dashboard
```

## Deployment

Both dashboards are configured for static export and Firebase Hosting.

### Deploy to Firebase:

1. **Client Dashboard:**
```bash
cd client-dashboard
firebase deploy
```

2. **Company Dashboard:**
```bash
cd company-dashboard
firebase deploy
```

## Configuration Files

### Next.js Configuration
Both dashboards use Next.js 14 with:
- Static export (`output: 'export'`)
- SWC minification
- React strict mode
- Unoptimized images for static export

### Firebase Configuration
- Hosting configured to serve from `out` directory
- Single-page application routing enabled

## Troubleshooting

### Build Failures

1. **Clear build cache:**
```bash
# For client dashboard
cd client-dashboard
rm -rf .next out

# For company dashboard
cd company-dashboard
rm -rf .next out
```

2. **Reinstall dependencies:**
```bash
# From root
rm -rf client-dashboard/node_modules company-dashboard/node_modules
npm run install:all
```

3. **Check TypeScript errors:**
```bash
cd client-dashboard
npm run type-check

cd company-dashboard
npm run type-check
```

### Environment Variables
Ensure all required environment variables are set:
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_PROJECT_ID`

## Scripts Reference

### Root Level Scripts
- `npm run dev` - Run both dashboards in development mode
- `npm run build` - Build both dashboards for production
- `npm run install:all` - Install dependencies for all projects
- `npm run lint` - Run linting for all projects

### Individual Project Scripts
Each dashboard has its own scripts:
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint
- `npm run type-check` - Check TypeScript types

## Technology Stack

- **Frontend Framework:** Next.js 14
- **UI Library:** React 18
- **Styling:** Tailwind CSS
- **Database:** Firebase Firestore
- **Authentication:** Firebase Auth
- **Hosting:** Firebase Hosting
- **Language:** TypeScript

## License

Private - All rights reserved

## Support

For issues or questions, please contact the development team.
