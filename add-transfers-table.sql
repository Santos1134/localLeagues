-- Add Player Transfers Table
-- Run this in Supabase SQL Editor to add transfer functionality

CREATE TABLE IF NOT EXISTS player_transfers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  from_team_id UUID NOT NULL REFERENCES teams(id),
  to_team_id UUID NOT NULL REFERENCES teams(id),
  transfer_date DATE NOT NULL DEFAULT CURRENT_DATE,
  transfer_fee DECIMAL(12, 2),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  approved_by UUID REFERENCES profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE player_transfers ENABLE ROW LEVEL SECURITY;

-- Allow admins full access
CREATE POLICY "Admins can manage transfers" ON player_transfers
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Allow everyone to view approved transfers
CREATE POLICY "Everyone can view approved transfers" ON player_transfers
  FOR SELECT
  USING (status = 'approved');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS player_transfers_player_id_idx ON player_transfers(player_id);
CREATE INDEX IF NOT EXISTS player_transfers_from_team_idx ON player_transfers(from_team_id);
CREATE INDEX IF NOT EXISTS player_transfers_to_team_idx ON player_transfers(to_team_id);
CREATE INDEX IF NOT EXISTS player_transfers_date_idx ON player_transfers(transfer_date);

-- Add trigger for updated_at
CREATE OR REPLACE FUNCTION update_player_transfers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER player_transfers_updated_at
  BEFORE UPDATE ON player_transfers
  FOR EACH ROW
  EXECUTE FUNCTION update_player_transfers_updated_at();
