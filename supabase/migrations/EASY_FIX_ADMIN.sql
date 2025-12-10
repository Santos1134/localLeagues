-- SIMPLE FIX FOR ADMIN LOGIN
-- Just copy this entire file and paste it into Supabase SQL Editor, then click RUN

-- Step 1: Allow users to read profiles (needed for login)
DROP POLICY IF EXISTS "Authenticated users can read all profiles" ON profiles;
CREATE POLICY "Authenticated users can read all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

-- Step 2: Fix the trigger so it doesn't block role updates
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'fan'),
    NEW.raw_user_meta_data->>'full_name'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error creating profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: See all your users and their roles
SELECT email, role, managed_cup_id, created_at
FROM profiles
ORDER BY created_at DESC;

-- Step 4: Update the admin role for liberialeagues@gmail.com
UPDATE profiles SET role = 'league_admin' WHERE email = 'liberialeagues@gmail.com';
