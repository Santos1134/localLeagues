-- Check RLS policies that might be blocking SELECT queries

-- Check if RLS is enabled on these tables
SELECT
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('teams', 'cup_teams_registry', 'leagues', 'divisions', 'players', 'cups')
ORDER BY tablename;

-- Check SELECT policies for these tables
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('teams', 'cup_teams_registry', 'leagues', 'divisions', 'players', 'cups')
  AND cmd = 'SELECT'
ORDER BY tablename, policyname;
