# Quick Start Guide

Get your Liberia Division League Management App up and running in minutes!

## 1. Install Dependencies

```bash
cd liberia-league-app
npm install
```

If you encounter any errors, try:
```bash
npm install --force
```

## 2. Set Up Your Database

### Step 1: Access Supabase
1. Go to https://ytmdnkghtnbotbnftlej.supabase.co
2. Log in to your Supabase account

### Step 2: Run Database Schema
1. Click on "SQL Editor" in the left sidebar
2. Click "New Query"
3. Open the file `database-schema.sql` in your code editor
4. Copy ALL the contents (Ctrl+A, Ctrl+C)
5. Paste into the Supabase SQL Editor
6. Click "Run" or press Ctrl+Enter
7. Wait for the success message

### Step 3: Verify Database Setup
1. Click on "Table Editor" in the left sidebar
2. You should see all these tables:
   - profiles
   - leagues
   - divisions
   - teams
   - players
   - matches
   - match_events
   - fan_votes
   - announcements

If you see all these tables, your database is set up correctly!

## 3. Start the Development Server

```bash
npm run dev
```

The app will start on [http://localhost:3000](http://localhost:3000)

## 4. Test the Application

Open your browser to http://localhost:3000

You should see:
- ✅ A green header with "Liberia League" branding
- ✅ Navigation menu (Fixtures, Standings, Teams, Players, Dashboard, Login)
- ✅ Hero section with welcome message
- ✅ Statistics section showing league stats
- ✅ Features section with 3 feature cards
- ✅ Call-to-action section at the bottom
- ✅ Footer with links and information

## 5. Next Steps

Now that your app is running, here's what to build next:

### Phase 1: Authentication (Do This First!)
1. Create login page at `app/(auth)/login/page.tsx`
2. Create signup page at `app/(auth)/signup/page.tsx`
3. Test user registration and login

### Phase 2: Admin Dashboard
1. Create admin dashboard at `app/(dashboard)/admin/page.tsx`
2. Build league creation form
3. Build division creation form

### Phase 3: Team & Player Management
1. Create team registration page
2. Create player registration form
3. Build team roster page

### Phase 4: Match Management
1. Build fixture generation system
2. Create match score submission interface
3. Display standings

## Troubleshooting

### Issue: npm install fails
**Solution**: Try these commands in order:
```bash
# Clean npm cache
npm cache clean --force

# Remove node_modules
rm -rf node_modules package-lock.json

# Reinstall
npm install
```

### Issue: "Module not found" errors
**Solution**: Make sure all imports use the correct path:
```typescript
import Component from '@/components/Component'  // ✅ Correct
import Component from '../components/Component' // ❌ Avoid
```

### Issue: Supabase connection error
**Solution**: Check your `.env.local` file:
```env
NEXT_PUBLIC_SUPABASE_URL=https://ytmdnkghtnbotbnftlej.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...
```

### Issue: Database tables not found
**Solution**: Re-run the database-schema.sql in Supabase SQL Editor

### Issue: Styling not working
**Solution**: Make sure Tailwind is configured correctly:
1. Check `tailwind.config.ts` exists
2. Check `app/globals.css` has Tailwind directives:
   ```css
   @tailwind base;
   @tailwind components;
   @tailwind utilities;
   ```

## Quick Commands Reference

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run linter
npm run lint

# Type check
npx tsc --noEmit

# Clean install
rm -rf node_modules package-lock.json && npm install
```

## Project Files Overview

```
Key Files to Know:
├── app/
│   ├── layout.tsx          # Main layout (Header + Footer)
│   ├── page.tsx            # Homepage
│   └── globals.css         # Global styles
├── components/
│   └── layout/
│       ├── Header.tsx      # Navigation header
│       └── Footer.tsx      # Footer
├── lib/
│   ├── supabase/
│   │   ├── client.ts       # Browser Supabase client
│   │   └── server.ts       # Server Supabase client
│   └── types/
│       └── database.types.ts # TypeScript types
├── .env.local              # Environment variables
├── database-schema.sql     # Database setup script
├── middleware.ts           # Auth middleware
└── package.json            # Dependencies
```

## Getting Help

1. Check the [README.md](README.md) for full documentation
2. Review [SETUP.md](SETUP.md) for detailed setup instructions
3. See [PROJECT_STATUS.md](PROJECT_STATUS.md) for current progress and roadmap
4. Read the code comments for inline documentation

## Important URLs

- **Local App**: http://localhost:3000
- **Supabase Dashboard**: https://ytmdnkghtnbotbnftlej.supabase.co
- **Next.js Docs**: https://nextjs.org/docs
- **Supabase Docs**: https://supabase.com/docs
- **TailwindCSS Docs**: https://tailwindcss.com/docs

---

**Ready to code?** Start with creating the authentication pages!

Good luck building the Liberia Division League Management App! ⚽🇱🇷
