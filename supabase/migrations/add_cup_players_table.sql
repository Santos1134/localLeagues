-- Add cup players table for player registration in cups
-- This allows teams to register specific players for cup competitions

CREATE TABLE IF NOT EXISTS cup_players (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cup_id UUID REFERENCES cups(id) ON DELETE CASCADE NOT NULL,
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE NOT NULL,
  player_id UUID REFERENCES players(id) ON DELETE CASCADE NOT NULL,
  jersey_number INTEGER,
  position TEXT,
  is_captain BOOLEAN DEFAULT false,
  registered_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(cup_id, team_id, player_id)
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_cup_players_cup_id ON cup_players(cup_id);
CREATE INDEX IF NOT EXISTS idx_cup_players_team_id ON cup_players(team_id);
CREATE INDEX IF NOT EXISTS idx_cup_players_player_id ON cup_players(player_id);

-- Enable RLS
ALTER TABLE cup_players ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Anyone can view cup players"
  ON cup_players FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins can manage cup players"
  ON cup_players FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'league_admin')
    )
  );

-- Add comment
COMMENT ON TABLE cup_players IS 'Players registered for cup competitions by their teams';
