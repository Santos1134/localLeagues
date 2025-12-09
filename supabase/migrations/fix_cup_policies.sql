-- Fix RLS policies for cups to allow creation without league_id

-- Drop existing policies
DROP POLICY IF EXISTS "Anyone can view cups" ON cups;
DROP POLICY IF EXISTS "Super admins can insert cups" ON cups;
DROP POLICY IF EXISTS "League admins can insert cups for their league" ON cups;
DROP POLICY IF EXISTS "Super admins can update any cup" ON cups;
DROP POLICY IF EXISTS "League admins can update cups for their league" ON cups;
DROP POLICY IF EXISTS "Super admins can delete any cup" ON cups;
DROP POLICY IF EXISTS "League admins can delete cups for their league" ON cups;

-- Recreate policies with correct logic for independent cups

-- Anyone can view cups
CREATE POLICY "Anyone can view cups"
  ON cups FOR SELECT
  TO public
  USING (true);

-- Admins (both super and league admins) can insert cups
CREATE POLICY "Admins can insert cups"
  ON cups FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'league_admin')
    )
  );

-- Admins (both super and league admins) can update cups
CREATE POLICY "Admins can update cups"
  ON cups FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'league_admin')
    )
  );

-- Admins (both super and league admins) can delete cups
CREATE POLICY "Admins can delete cups"
  ON cups FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'league_admin')
    )
  );
