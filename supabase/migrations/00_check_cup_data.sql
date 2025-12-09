-- Check for existing cup data before migration
-- Run this first to see if you have data that needs preservation

-- Check cups
SELECT 'Cups Count:' as info, COUNT(*) as count FROM cups;

-- Check cup teams (old structure)
SELECT 'Cup Teams Count:' as info, COUNT(*) as count FROM cup_teams;

-- Check cup matches
SELECT 'Cup Matches Count:' as info, COUNT(*) as count FROM cup_matches;

-- Check cup groups
SELECT 'Cup Groups Count:' as info, COUNT(*) as count FROM cup_groups;

-- Check if columns exist
SELECT
  'Column Existence Check' as info,
  EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles'
    AND column_name = 'managed_cup_id'
  ) as managed_cup_id_exists,
  EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cup_teams'
    AND column_name = 'team_id'
  ) as old_team_id_exists,
  EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cup_teams'
    AND column_name = 'cup_team_id'
  ) as new_cup_team_id_exists;

-- Show any existing cup data
SELECT c.name as cup_name, COUNT(ct.id) as teams_count
FROM cups c
LEFT JOIN cup_teams ct ON c.id = ct.cup_id
GROUP BY c.id, c.name;
