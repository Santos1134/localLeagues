# Cup Team Logos Setup Checklist

## ✅ Code Implementation Status
All code changes have been pushed to GitHub:
- ✅ Independent cup teams system implemented
- ✅ Team creation form with logo URL field
- ✅ Team logo display in Teams tab
- ✅ Team logo display in Fixtures page
- ✅ Edit functionality for team information

## 🔧 Required Setup Steps

### Step 1: Run Database Migration (CRITICAL!)
You MUST run this migration in your Supabase SQL Editor:

**File:** `supabase/migrations/create_independent_cup_teams_safe.sql`

**Location:** Supabase Dashboard → SQL Editor → New Query → Paste migration content → Run

This migration creates:
- `cup_teams_registry` table (stores team name, logo_url, stadium, etc.)
- `cup_players_registry` table (for future player management)
- Updates `cup_teams` and `cup_matches` to reference the registry
- Sets up proper RLS policies

**⚠️ Without this migration, team logos WILL NOT work!**

### Step 2: Test Team Logo Display

After running the migration:

1. **Create a Cup Competition**
   - Go to `/admin/cups`
   - Click "Create New Cup"
   - Fill in cup details

2. **Add a Team with Logo**
   - Go to the cup details page
   - Click "Teams" tab
   - Click "+ Add Team"
   - Fill in:
     - Team Name (required): e.g., "Monrovia United"
     - Logo URL: e.g., "https://example.com/logo.png"
     - Stadium, City, Coach (optional)
   - Click "Create & Add Team"

3. **Verify Logo Displays**
   - Team logo should appear immediately in the Teams tab
   - If no logo URL provided, team initials show in placeholder
   - Team info displays: name, stadium, city, coach

4. **Check Fixtures Page**
   - Create a cup match for this team
   - Go to `/fixtures`
   - Team logo should display in the match card

## 🐛 Troubleshooting

### Logo Not Showing After Adding Team?

**Check 1: Migration Status**
```sql
-- Run in Supabase SQL Editor to verify tables exist
SELECT table_name FROM information_schema.tables
WHERE table_name IN ('cup_teams_registry', 'cup_players_registry');
```
Should return both table names.

**Check 2: Logo URL Valid**
- Make sure the URL is publicly accessible
- Try opening the URL in a browser
- Check that it's a direct image link (ends in .png, .jpg, etc.)

**Check 3: Data in Database**
```sql
-- Check if team was created with logo
SELECT id, name, logo_url FROM cup_teams_registry;
```

**Check 4: Browser Cache**
- Hard refresh: Ctrl+F5 (Windows) or Cmd+Shift+R (Mac)
- Clear browser cache
- Try incognito/private browsing mode

### Image Shows Broken Icon?

The code has an error handler that hides broken images:
```javascript
onError={(e) => {
  e.currentTarget.style.display = 'none'
}}
```

If logo URL is invalid or broken:
- The image will be hidden
- Team initials placeholder will show instead
- Check the URL is correct

## 📋 Current Implementation Details

### Team Logo Display Locations:

1. **Teams Tab** (`/admin/cups/[id]` → Teams)
   - Shows 48x48px logo or initials placeholder
   - Displays all team info (name, stadium, city, coach)
   - Edit button to update logo URL

2. **Fixtures Page** (`/fixtures`)
   - Shows team logos in match cards
   - Works for both league and cup matches
   - 32x32px rounded logos

3. **Cup Matches**
   - Fetches from `cup_teams_registry` via foreign keys
   - `home_cup_team_id` → `cup_teams_registry.id`
   - `away_cup_team_id` → `cup_teams_registry.id`

### Database Structure:

```
cup_teams_registry (independent team info)
├── id (UUID)
├── cup_id (reference to cups)
├── name (team name)
├── logo_url (⭐ team logo URL)
├── short_name
├── stadium
├── city
└── coach

cup_teams (stats tracking)
├── id
├── cup_id
├── cup_team_id (→ cup_teams_registry.id)
├── points, played, won, etc.
└── group_id

cup_matches
├── id
├── cup_id
├── home_cup_team_id (→ cup_teams_registry.id)
├── away_cup_team_id (→ cup_teams_registry.id)
├── home_score, away_score
└── status, match_date, etc.
```

## ✅ What Should Work Now:

1. ✅ Create cup competitions completely independent from leagues
2. ✅ Add teams by typing in name, logo URL, stadium, etc.
3. ✅ Team logos display in Teams tab
4. ✅ Team logos display in Fixtures page
5. ✅ Edit team information including logo URL
6. ✅ Team initials placeholder if no logo
7. ✅ Cup and league matches shown together in fixtures

## 🚀 Next Steps:

1. Run the migration if not done yet
2. Test creating a cup with teams
3. Add logo URLs to teams
4. Verify logos display correctly
5. Report any issues found

---

**Last Updated:** After implementing team logo display and edit functionality
**Status:** ✅ Code Complete - Migration Required
