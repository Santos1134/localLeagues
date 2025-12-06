# Liberia Division League Management App - Setup Guide

## Project Overview

A comprehensive web-based platform to manage local sports division leagues in Liberia. The app supports league administrators, team managers, match officials, players, and fans with features for organizing divisions, scheduling matches, tracking results, and engaging fans.

## Tech Stack

- **Frontend**: Next.js 15+ with TypeScript
- **Styling**: TailwindCSS
- **Backend**: Supabase (PostgreSQL database, Authentication, Real-time subscriptions)
- **Hosting**: Supabase

## Prerequisites

- Node.js 18+ installed
- npm or yarn
- Supabase account (already configured)

## Setup Instructions

### 1. Install Dependencies

```bash
cd liberia-league-app
npm install
```

### 2. Environment Variables

The `.env.local` file has already been created with your Supabase credentials:

```
NEXT_PUBLIC_SUPABASE_URL=https://ytmdnkghtnbotbnftlej.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...
```

### 3. Database Setup

#### Option A: Using Supabase Dashboard

1. Go to https://ytmdnkghtnbotbnftlej.supabase.co
2. Navigate to **SQL Editor**
3. Copy the contents of `database-schema.sql`
4. Paste and run the SQL script

#### Option B: Using Supabase CLI

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref ytmdnkghtnbotbnftlej

# Run migrations
supabase db push
```

### 4. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the app.

## Database Schema Overview

### Core Tables

1. **profiles** - User profiles with role-based access
2. **leagues** - Sports leagues (football, basketball, etc.)
3. **divisions** - Divisions within leagues (Division 1, 2, 3, etc.)
4. **teams** - Team information and management
5. **players** - Player profiles and statistics
6. **matches** - Fixture and match data
7. **match_events** - Goals, cards, substitutions, etc.
8. **fan_votes** - Fan engagement voting
9. **announcements** - League announcements

### Views

1. **division_standings** - Auto-calculated league standings
2. **player_stats** - Aggregated player statistics

## User Roles

1. **Admin** - Full system control
2. **Team Manager** - Manage team and players
3. **Match Official** - Submit match scores and reports
4. **Player** - View stats and profile
5. **Fan** - View fixtures, results, and vote

## Features Roadmap

### MVP (Minimum Viable Product)
- [x] Project setup and configuration
- [x] Database schema design
- [ ] User authentication and role management
- [ ] Admin dashboard
- [ ] League and division management
- [ ] Team registration
- [ ] Player management
- [ ] Fixture generation (round-robin)
- [ ] Match score submission
- [ ] Real-time standings
- [ ] Public fan pages

### Phase 2
- [ ] Advanced analytics and reports
- [ ] Fan voting system
- [ ] Push notifications
- [ ] PDF/CSV export
- [ ] Social media integration

### Phase 3
- [ ] Mobile app (React Native)
- [ ] Sponsor/advertisement management
- [ ] Live match updates
- [ ] Video highlights integration

## Project Structure

```
liberia-league-app/
├── app/                    # Next.js app directory
│   ├── (auth)/            # Authentication pages
│   ├── (dashboard)/       # Admin/manager dashboards
│   ├── (public)/          # Public fan pages
│   └── api/               # API routes
├── lib/
│   ├── supabase/          # Supabase client configuration
│   ├── types/             # TypeScript types
│   └── utils/             # Utility functions
├── components/            # Reusable React components
│   ├── ui/               # UI components
│   ├── forms/            # Form components
│   └── dashboard/        # Dashboard components
├── database-schema.sql    # Database schema
└── .env.local            # Environment variables
```

## Development Guidelines

### Code Style
- Use TypeScript for type safety
- Follow Next.js App Router conventions
- Use server components by default, client components when needed
- Implement proper error handling and loading states

### Security
- All database tables have Row Level Security (RLS) enabled
- Role-based access control enforced at database level
- Sensitive operations require authentication

### Performance
- Database indexes on frequently queried columns
- Optimized views for standings and statistics
- Real-time subscriptions for live updates

## API Routes

The app will use Next.js API routes and Server Actions for:
- User authentication
- Data mutations
- File uploads
- Report generation

## Testing

```bash
# Run tests (to be implemented)
npm test

# Type checking
npm run type-check

# Linting
npm run lint
```

## Deployment

### Vercel (Recommended)

1. Push code to GitHub
2. Import project to Vercel
3. Add environment variables
4. Deploy

### Manual Deployment

```bash
npm run build
npm start
```

## Support

For issues or questions, please refer to:
- Next.js Documentation: https://nextjs.org/docs
- Supabase Documentation: https://supabase.com/docs
- TailwindCSS Documentation: https://tailwindcss.com/docs

## License

Proprietary - Liberia Division League Management System
