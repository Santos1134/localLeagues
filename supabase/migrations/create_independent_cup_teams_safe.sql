-- SAFE Migration: Create independent team registry for cups
-- This version preserves existing data and handles edge cases

-- ============================================
-- PART 1: Create new tables
-- ============================================

-- Create cup_teams_registry table (independent teams for cups)
CREATE TABLE IF NOT EXISTS cup_teams_registry (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cup_id UUID REFERENCES cups(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  short_name TEXT,
  logo_url TEXT,
  founded_year INTEGER,
  stadium TEXT,
  city TEXT,
  coach TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(cup_id, name)
);

-- Create cup_players_registry table (players specific to cup teams)
CREATE TABLE IF NOT EXISTS cup_players_registry (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cup_team_id UUID REFERENCES cup_teams_registry(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  jersey_number INTEGER,
  position TEXT,
  date_of_birth DATE,
  nationality TEXT,
  is_captain BOOLEAN DEFAULT false,
  goals INTEGER DEFAULT 0,
  assists INTEGER DEFAULT 0,
  yellow_cards INTEGER DEFAULT 0,
  red_cards INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW') NOT NULL,
  UNIQUE(cup_team_id, jersey_number)
);

-- ============================================
-- PART 2: Migrate existing data (if any)
-- ============================================

-- Migrate existing cup teams to cup_teams_registry
DO $$
DECLARE
  team_record RECORD;
  new_team_id UUID;
BEGIN
  -- Check if old structure exists
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cup_teams' AND column_name = 'team_id'
  ) THEN
    -- Loop through existing cup teams and create registry entries
    FOR team_record IN
      SELECT DISTINCT ct.cup_id, t.name
      FROM cup_teams ct
      JOIN teams t ON ct.team_id = t.id
    LOOP
      -- Insert into cup_teams_registry
      INSERT INTO cup_teams_registry (cup_id, name)
      VALUES (team_record.cup_id, team_record.name)
      ON CONFLICT (cup_id, name) DO NOTHING
      RETURNING id INTO new_team_id;

      -- Update cup_teams to reference new registry (if new_team_id was created)
      IF new_team_id IS NOT NULL THEN
        UPDATE cup_teams ct
        SET team_id = new_team_id
        FROM teams t
        WHERE ct.cup_id = team_record.cup_id
        AND ct.team_id = t.id
        AND t.name = team_record.name;
      END IF;
    END LOOP;

    RAISE NOTICE 'Successfully migrated existing cup teams to registry';
  END IF;
END $$;

-- ============================================
-- PART 3: Update table structure
-- ============================================

-- Only rename if old column exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cup_teams' AND column_name = 'team_id'
  ) THEN
    -- Drop old foreign key
    ALTER TABLE cup_teams DROP CONSTRAINT IF EXISTS cup_teams_team_id_fkey;

    -- Rename column
    ALTER TABLE cup_teams RENAME COLUMN team_id TO cup_team_id;

    RAISE NOTICE 'Renamed team_id to cup_team_id in cup_teams table';
  END IF;

  -- Add new foreign key
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'cup_teams_cup_team_id_fkey'
  ) THEN
    ALTER TABLE cup_teams
    ADD CONSTRAINT cup_teams_cup_team_id_fkey
    FOREIGN KEY (cup_team_id) REFERENCES cup_teams_registry(id) ON DELETE CASCADE;

    RAISE NOTICE 'Added foreign key to cup_teams_registry';
  END IF;
END $$;

-- Update cup_matches table
DO $$
BEGIN
  -- Rename home_team_id
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cup_matches' AND column_name = 'home_team_id'
  ) THEN
    ALTER TABLE cup_matches DROP CONSTRAINT IF EXISTS cup_matches_home_team_id_fkey;
    ALTER TABLE cup_matches RENAME COLUMN home_team_id TO home_cup_team_id;
  END IF;

  -- Rename away_team_id
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'cup_matches' AND column_name = 'away_team_id'
  ) THEN
    ALTER TABLE cup_matches DROP CONSTRAINT IF EXISTS cup_matches_away_team_id_fkey;
    ALTER TABLE cup_matches RENAME COLUMN away_team_id TO away_cup_team_id;
  END IF;

  -- Add new foreign keys
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'cup_matches_home_cup_team_id_fkey'
  ) THEN
    ALTER TABLE cup_matches
    ADD CONSTRAINT cup_matches_home_cup_team_id_fkey
    FOREIGN KEY (home_cup_team_id) REFERENCES cup_teams_registry(id) ON DELETE CASCADE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'cup_matches_away_cup_team_id_fkey'
  ) THEN
    ALTER TABLE cup_matches
    ADD CONSTRAINT cup_matches_away_cup_team_id_fkey
    FOREIGN KEY (away_cup_team_id) REFERENCES cup_teams_registry(id) ON DELETE CASCADE;
  END IF;

  RAISE NOTICE 'Updated cup_matches table structure';
END $$;

-- ============================================
-- PART 4: Create indexes
-- ============================================

CREATE INDEX IF NOT EXISTS idx_cup_teams_registry_cup_id ON cup_teams_registry(cup_id);
CREATE INDEX IF NOT EXISTS idx_cup_players_registry_cup_team_id ON cup_players_registry(cup_team_id);

-- ============================================
-- PART 5: Enable RLS and create policies
-- ============================================

ALTER TABLE cup_teams_registry ENABLE ROW LEVEL SECURITY;
ALTER TABLE cup_players_registry ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can view cup teams registry" ON cup_teams_registry;
DROP POLICY IF EXISTS "Admins can manage cup teams registry" ON cup_teams_registry;
DROP POLICY IF EXISTS "Anyone can view cup players registry" ON cup_players_registry;
DROP POLICY IF EXISTS "Admins can manage cup players registry" ON cup_players_registry;

-- RLS Policies for cup_teams_registry
CREATE POLICY "Anyone can view cup teams registry"
  ON cup_teams_registry FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins can manage cup teams registry"
  ON cup_teams_registry FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND (
        -- Super admin
        (p.role = 'admin' AND p.managed_league_id IS NULL AND COALESCE(p.managed_cup_id, '00000000-0000-0000-0000-000000000000'::uuid) = '00000000-0000-0000-0000-000000000000'::uuid) OR
        -- League admin (not cup-specific)
        (p.role = 'league_admin' AND COALESCE(p.managed_cup_id, '00000000-0000-0000-0000-000000000000'::uuid) = '00000000-0000-0000-0000-000000000000'::uuid) OR
        -- Cup admin managing this specific cup
        (p.role = 'league_admin' AND p.managed_cup_id = cup_teams_registry.cup_id)
      )
    )
  );

-- RLS Policies for cup_players_registry
CREATE POLICY "Anyone can view cup players registry"
  ON cup_players_registry FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins can manage cup players registry"
  ON cup_players_registry FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      LEFT JOIN cup_teams_registry ctr ON ctr.id = cup_players_registry.cup_team_id
      WHERE p.id = auth.uid()
      AND (
        -- Super admin
        (p.role = 'admin' AND p.managed_league_id IS NULL AND COALESCE(p.managed_cup_id, '00000000-0000-0000-0000-000000000000'::uuid) = '00000000-0000-0000-0000-000000000000'::uuid) OR
        -- League admin (not cup-specific)
        (p.role = 'league_admin' AND COALESCE(p.managed_cup_id, '00000000-0000-0000-0000-000000000000'::uuid) = '00000000-0000-0000-0000-000000000000'::uuid) OR
        -- Cup admin managing this specific cup
        (p.role = 'league_admin' AND p.managed_cup_id = ctr.cup_id)
      )
    )
  );

-- ============================================
-- PART 6: Add triggers and comments
-- ============================================

-- Add updated_at triggers
DROP TRIGGER IF EXISTS update_cup_teams_registry_updated_at ON cup_teams_registry;
CREATE TRIGGER update_cup_teams_registry_updated_at
  BEFORE UPDATE ON cup_teams_registry
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_cup_players_registry_updated_at ON cup_players_registry;
CREATE TRIGGER update_cup_players_registry_updated_at
  BEFORE UPDATE ON cup_players_registry
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON TABLE cup_teams_registry IS 'Independent teams registered for cup competitions (not linked to league teams)';
COMMENT ON TABLE cup_players_registry IS 'Players belonging to cup teams (independent from league players)';

-- ============================================
-- PART 7: Verification
-- ============================================

DO $$
DECLARE
  teams_count INTEGER;
  players_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO teams_count FROM cup_teams_registry;
  SELECT COUNT(*) INTO players_count FROM cup_players_registry;

  RAISE NOTICE '============================================';
  RAISE NOTICE 'Migration completed successfully!';
  RAISE NOTICE 'Cup Teams Registry: % teams', teams_count;
  RAISE NOTICE 'Cup Players Registry: % players', players_count;
  RAISE NOTICE '============================================';
END $$;
