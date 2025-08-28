# Firebase Admin Setup for User Management

To enable user management functionality in the Company Dashboard, you need to configure Firebase Admin SDK with service account credentials.

## Step 1: Get Service Account Credentials

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `inventoryapp-55dd5`
3. Click the gear icon → **Project Settings**
4. Navigate to the **Service Accounts** tab
5. Click **"Generate new private key"**
6. Download the JSON file (keep it secure!)

## Step 2: Configure Environment Variables

1. Create a `.env.local` file in the `company-dashboard` directory
2. Extract the following values from your downloaded JSON file and add them to `.env.local`:

```bash
# Firebase Admin SDK Configuration
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@inventoryapp-55dd5.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
YOUR_ACTUAL_PRIVATE_KEY_CONTENT_HERE
-----END PRIVATE KEY-----"
FIREBASE_PROJECT_ID=inventoryapp-55dd5
```

**Important Notes:**
- Replace `YOUR_ACTUAL_PRIVATE_KEY_CONTENT_HERE` with the actual private key from the JSON file
- Keep the quotes around the private key
- The private key should include the `\n` characters for line breaks
- Never commit the `.env.local` file to version control

## Step 3: Restart Development Server

After adding the credentials:

```bash
# Stop the current server (Ctrl+C)
# Then restart:
npm run dev
```

## Step 4: Test User Management

1. Go to http://localhost:3001/users
2. You should now see the user management interface
3. You can:
   - View all registered users from your iOS app
   - Create new users
   - Edit user details and roles
   - Delete users (with confirmation)
   - See user statistics and activity

## Features Available

### User Management Dashboard
- **User List**: View all users with details like email, role, status, properties count
- **User Creation**: Create new users with email/password and assign roles
- **User Editing**: Update user information, roles, and status
- **User Deletion**: Remove users (with confirmation)
- **Search**: Search users by email, name, or company
- **Stats**: Quick overview of total users, active users, verified emails

### User Roles
- **Client**: Regular users who manage their own properties
- **Manager**: Can view and manage multiple clients
- **Admin**: Full access to all features

### Integration with iOS App
- Users created in the dashboard can immediately log into the iOS app
- Users who sign up through the iOS app appear in the dashboard
- Role-based access control works across both platforms

## Security Notes

1. **Service Account Key**: Keep your service account key secure and never expose it
2. **Environment Variables**: Use `.env.local` for local development only
3. **Production**: Use proper secret management for production deployments
4. **Permissions**: Review Firebase security rules regularly

## Troubleshooting

### "Firebase Admin not initialized" Error
- Check that your `.env.local` file exists and has the correct values
- Ensure the private key is properly formatted with `\n` characters
- Restart the development server after making changes

### "Permission Denied" Errors
- Verify your service account has the correct permissions
- Check that you're using the right project ID

### Users Not Appearing
- Make sure users have signed up through the iOS app or been created via the dashboard
- Check Firebase Auth console to see if users exist there

## Need Help?

If you encounter issues, check:
1. Firebase Console logs
2. Browser developer console
3. Server terminal for error messages
4. Ensure iOS app and dashboard are using the same Firebase project