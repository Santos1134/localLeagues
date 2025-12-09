-- Add support for cup-specific admins
-- Admins can now manage EITHER a league OR a cup, not both

-- Add managed_cup_id column to profiles
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS managed_cup_id UUID REFERENCES cups(id) ON DELETE CASCADE;

-- Add constraint to ensure admin manages either league OR cup, not both
ALTER TABLE profiles
ADD CONSTRAINT check_single_admin_assignment
CHECK (
  (managed_league_id IS NULL AND managed_cup_id IS NULL) OR  -- Super admin
  (managed_league_id IS NOT NULL AND managed_cup_id IS NULL) OR  -- League admin
  (managed_league_id IS NULL AND managed_cup_id IS NOT NULL)     -- Cup admin
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_profiles_managed_cup_id ON profiles(managed_cup_id);

-- Add comment
COMMENT ON COLUMN profiles.managed_cup_id IS 'For cup admins: the specific cup they can manage. NULL for super admins and league admins.';
COMMENT ON CONSTRAINT check_single_admin_assignment ON profiles IS 'Ensures admin manages either a league OR a cup, never both';

-- Update RLS policies for cups to include cup-specific admins

-- Drop existing cup policies
DROP POLICY IF EXISTS "Admins can insert cups" ON cups;
DROP POLICY IF EXISTS "Admins can update cups" ON cups;
DROP POLICY IF EXISTS "Admins can delete cups" ON cups;

-- Recreate with correct logic

-- Super admins and league admins can insert cups
CREATE POLICY "Admins can insert cups"
  ON cups FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'league_admin')
      AND profiles.managed_cup_id IS NULL  -- Not a cup admin
    )
  );

-- Super admins, league admins, and cup-specific admins can update cups
CREATE POLICY "Admins can update cups"
  ON cups FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND (
        -- Super admin
        (profiles.role = 'admin' AND profiles.managed_league_id IS NULL AND profiles.managed_cup_id IS NULL) OR
        -- League admin
        (profiles.role = 'league_admin' AND profiles.managed_cup_id IS NULL) OR
        -- Cup admin managing this specific cup
        (profiles.role = 'league_admin' AND profiles.managed_cup_id = cups.id)
      )
    )
  );

-- Super admins, league admins, and cup-specific admins can delete cups
CREATE POLICY "Admins can delete cups"
  ON cups FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND (
        -- Super admin
        (profiles.role = 'admin' AND profiles.managed_league_id IS NULL AND profiles.managed_cup_id IS NULL) OR
        -- League admin
        (profiles.role = 'league_admin' AND profiles.managed_cup_id IS NULL) OR
        -- Cup admin managing this specific cup
        (profiles.role = 'league_admin' AND profiles.managed_cup_id = cups.id)
      )
    )
  );

-- Update cup_groups policies
DROP POLICY IF EXISTS "Admins can manage cup groups" ON cup_groups;

CREATE POLICY "Admins can manage cup groups"
  ON cup_groups FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      LEFT JOIN cups c ON c.id = cup_groups.cup_id
      WHERE p.id = auth.uid()
      AND (
        -- Super admin
        (p.role = 'admin' AND p.managed_league_id IS NULL AND p.managed_cup_id IS NULL) OR
        -- League admin (not cup-specific)
        (p.role = 'league_admin' AND p.managed_cup_id IS NULL) OR
        -- Cup admin managing this specific cup
        (p.role = 'league_admin' AND p.managed_cup_id = c.id)
      )
    )
  );

-- Update cup_teams policies
DROP POLICY IF EXISTS "Admins can manage cup teams" ON cup_teams;

CREATE POLICY "Admins can manage cup teams"
  ON cup_teams FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      LEFT JOIN cups c ON c.id = cup_teams.cup_id
      WHERE p.id = auth.uid()
      AND (
        -- Super admin
        (p.role = 'admin' AND p.managed_league_id IS NULL AND p.managed_cup_id IS NULL) OR
        -- League admin (not cup-specific)
        (p.role = 'league_admin' AND p.managed_cup_id IS NULL) OR
        -- Cup admin managing this specific cup
        (p.role = 'league_admin' AND p.managed_cup_id = c.id)
      )
    )
  );

-- Update cup_matches policies
DROP POLICY IF EXISTS "Admins can manage cup matches" ON cup_matches;

CREATE POLICY "Admins can manage cup matches"
  ON cup_matches FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      LEFT JOIN cups c ON c.id = cup_matches.cup_id
      WHERE p.id = auth.uid()
      AND (
        -- Super admin
        (p.role = 'admin' AND p.managed_league_id IS NULL AND p.managed_cup_id IS NULL) OR
        -- League admin (not cup-specific)
        (p.role = 'league_admin' AND p.managed_cup_id IS NULL) OR
        -- Cup admin managing this specific cup
        (p.role = 'league_admin' AND p.managed_cup_id = c.id)
      )
    )
  );

-- Update cup_players policies
DROP POLICY IF EXISTS "Admins can manage cup players" ON cup_players;

CREATE POLICY "Admins can manage cup players"
  ON cup_players FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      LEFT JOIN cups c ON c.id = cup_players.cup_id
      WHERE p.id = auth.uid()
      AND (
        -- Super admin
        (p.role = 'admin' AND p.managed_league_id IS NULL AND p.managed_cup_id IS NULL) OR
        -- League admin (not cup-specific)
        (p.role = 'league_admin' AND p.managed_cup_id IS NULL) OR
        -- Cup admin managing this specific cup
        (p.role = 'league_admin' AND p.managed_cup_id = c.id)
      )
    )
  );
