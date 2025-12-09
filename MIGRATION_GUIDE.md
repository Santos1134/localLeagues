# Database Migration Guide

This guide explains the database migrations you need to run to enable the complete cup management system and administrator features.

## Prerequisites

1. Access to your Supabase SQL Editor
2. Supabase project with the base league system already set up

## Migration Steps

Run these migrations IN ORDER in your Supabase SQL Editor:

### Step 1: Fix Cup Creation Policies

**File:** `supabase/migrations/fix_cup_policies.sql`

**Purpose:** Allows admins to create cups without league restrictions (since cups are now independent)

**What it does:**
- Updates RLS policies to allow both super admins and league admins to create cups
- Removes the league_id restriction that was blocking cup creation

**Run this first** to fix the immediate cup creation issue.

---

### Step 2: Add Cup Players Table

**File:** `supabase/migrations/add_cup_players_table.sql`

**Purpose:** Creates a table for registering players to cup competitions

**What it does:**
- Creates `cup_players` table
- Allows teams to register specific players for cups
- Each team can register multiple players per cup
- Prevents duplicate player registrations

---

### Step 3: Add Cup Admin Support

**File:** `supabase/migrations/add_cup_admin_support.sql`

**Purpose:** Enables cup-specific administrators

**What it does:**
- Adds `managed_cup_id` column to profiles
- Adds constraint ensuring admins manage EITHER a league OR a cup (never both)
- Updates all RLS policies to support cup administrators
- Cup admins can manage their assigned cup only
- League admins can manage their assigned league only
- Super admins can manage everything

**Important:** This migration enforces that each admin can only manage ONE thing:
- Super Admin: `managed_league_id = NULL` AND `managed_cup_id = NULL`
- League Admin: `managed_league_id = <UUID>` AND `managed_cup_id = NULL`
- Cup Admin: `managed_league_id = NULL` AND `managed_cup_id = <UUID>`

---

## Verification

After running all migrations, verify they worked:

```sql
-- Check if cup_players table exists
SELECT * FROM cup_players LIMIT 1;

-- Check if managed_cup_id column exists
SELECT managed_cup_id FROM profiles LIMIT 1;

-- Check if constraint exists
SELECT conname FROM pg_constraint WHERE conname = 'check_single_admin_assignment';

-- Test cup creation (should work now)
-- Try creating a cup from the admin panel
```

## What's New

### For Users

1. **Cup Management System**
   - Create standalone cup competitions
   - Add teams from any league/division
   - Generate groups automatically
   - Create group stage fixtures
   - View standings
   - Track cup progression (draft → group stage → knockout → completed)

2. **Administrator System**
   - Create league-specific administrators
   - Create cup-specific administrators
   - Each admin manages either ONE league OR ONE cup
   - Better permission isolation

### For Developers

1. **New Tables:**
   - `cup_players` - Player registration for cups

2. **New Columns:**
   - `profiles.managed_cup_id` - Cup assignment for cup admins

3. **New Constraints:**
   - `check_single_admin_assignment` - Ensures single admin assignment

4. **Updated RLS Policies:**
   - All cup-related tables now support cup-specific admins
   - Proper isolation between league admins and cup admins

## Troubleshooting

### Issue: Cup creation still not working

**Solution:** Make sure you ran `fix_cup_policies.sql` first

### Issue: Can't create cup admin

**Solution:**
1. Check if `managed_cup_id` column exists in profiles
2. Run `add_cup_admin_support.sql` migration

### Issue: Admin can see both league and cup options

**Solution:** The constraint is working. Admins can be ASSIGNED to either, but only one at a time

### Issue: Existing admins have issues after migration

**Solution:** Existing league admins should work fine. Their `managed_cup_id` will be NULL by default.

## Rollback (if needed)

If you need to rollback these changes:

```sql
-- Remove cup admin support
ALTER TABLE profiles DROP COLUMN IF EXISTS managed_cup_id CASCADE;
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS check_single_admin_assignment;

-- Drop cup players table
DROP TABLE IF EXISTS cup_players CASCADE;

-- Revert to old cup policies (run the original migration)
```

## Support

If you encounter issues:
1. Check the Supabase logs for error messages
2. Verify all migrations ran successfully
3. Check browser console for any client-side errors
4. Ensure you're logged in as a super admin when testing

## Summary

After running all migrations, you'll have:
- ✅ Working cup creation
- ✅ Player registration system for cups
- ✅ Cup-specific administrators
- ✅ League-specific administrators
- ✅ Proper permission isolation
- ✅ Comprehensive cup management interface
