-- Liberia Division League Management App - Database Schema
-- This schema supports user management, leagues, divisions, teams, players, fixtures, and match management

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. USER ROLES & AUTHENTICATION
-- =====================================================

-- Custom user roles enum
CREATE TYPE user_role AS ENUM ('admin', 'team_manager', 'match_official', 'player', 'fan');

-- Profiles table (extends Supabase auth.users)
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role user_role NOT NULL DEFAULT 'fan',
    avatar_url TEXT,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Public profiles are viewable by everyone" ON profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- =====================================================
-- 2. LEAGUES & DIVISIONS
-- =====================================================

-- Sport type enum
CREATE TYPE sport_type AS ENUM ('football', 'basketball', 'volleyball');

-- Leagues table
CREATE TABLE leagues (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    sport sport_type NOT NULL DEFAULT 'football',
    description TEXT,
    season_start_date DATE NOT NULL,
    season_end_date DATE NOT NULL,
    logo_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE leagues ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Leagues are viewable by everyone" ON leagues
    FOR SELECT USING (true);

CREATE POLICY "Only admins can manage leagues" ON leagues
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Divisions table
CREATE TABLE divisions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    league_id UUID REFERENCES leagues(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    tier INTEGER NOT NULL DEFAULT 1, -- Division 1, 2, 3, etc.
    max_teams INTEGER DEFAULT 16,
    promotion_spots INTEGER DEFAULT 2,
    relegation_spots INTEGER DEFAULT 2,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(league_id, name)
);

ALTER TABLE divisions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Divisions are viewable by everyone" ON divisions
    FOR SELECT USING (true);

CREATE POLICY "Only admins can manage divisions" ON divisions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- 3. TEAMS & PLAYERS
-- =====================================================

-- Teams table
CREATE TABLE teams (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    short_name TEXT,
    logo_url TEXT,
    home_city TEXT,
    home_venue TEXT,
    founded_year INTEGER,
    manager_id UUID REFERENCES profiles(id),
    division_id UUID REFERENCES divisions(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(name, division_id)
);

ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Teams are viewable by everyone" ON teams
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage all teams" ON teams
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Team managers can manage own team" ON teams
    FOR UPDATE USING (manager_id = auth.uid());

-- Player position enum
CREATE TYPE player_position AS ENUM (
    'goalkeeper', 'defender', 'midfielder', 'forward', 'substitute'
);

-- Players table
CREATE TABLE players (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id),
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    full_name TEXT NOT NULL,
    jersey_number INTEGER,
    position player_position,
    date_of_birth DATE,
    nationality TEXT DEFAULT 'Liberia',
    height_cm INTEGER,
    weight_kg INTEGER,
    photo_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(team_id, jersey_number)
);

ALTER TABLE players ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players are viewable by everyone" ON players
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage all players" ON players
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Team managers can manage their players" ON players
    FOR ALL USING (
        team_id IN (
            SELECT id FROM teams WHERE manager_id = auth.uid()
        )
    );

-- =====================================================
-- 4. FIXTURES & MATCHES
-- =====================================================

-- Match status enum
CREATE TYPE match_status AS ENUM ('scheduled', 'live', 'completed', 'postponed', 'cancelled');

-- Fixtures/Matches table
CREATE TABLE matches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    division_id UUID REFERENCES divisions(id) ON DELETE CASCADE,
    round_number INTEGER NOT NULL,
    home_team_id UUID REFERENCES teams(id),
    away_team_id UUID REFERENCES teams(id),
    match_date TIMESTAMP WITH TIME ZONE NOT NULL,
    venue TEXT,
    referee_id UUID REFERENCES profiles(id),
    status match_status DEFAULT 'scheduled',
    home_score INTEGER DEFAULT 0,
    away_score INTEGER DEFAULT 0,
    attendance INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CHECK (home_team_id != away_team_id)
);

ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Matches are viewable by everyone" ON matches
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage all matches" ON matches
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Match officials can update assigned matches" ON matches
    FOR UPDATE USING (referee_id = auth.uid());

-- Match events enum
CREATE TYPE event_type AS ENUM ('goal', 'yellow_card', 'red_card', 'substitution', 'penalty', 'own_goal');

-- Match events table
CREATE TABLE match_events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id),
    player_id UUID REFERENCES players(id),
    event_type event_type NOT NULL,
    minute INTEGER NOT NULL,
    extra_time_minute INTEGER DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE match_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Match events are viewable by everyone" ON match_events
    FOR SELECT USING (true);

CREATE POLICY "Admins and match officials can manage events" ON match_events
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND (
                role = 'admin' OR
                (role = 'match_official' AND id IN (
                    SELECT referee_id FROM matches WHERE id = match_id
                ))
            )
        )
    );

-- =====================================================
-- 5. STANDINGS (Calculated View)
-- =====================================================

CREATE OR REPLACE VIEW division_standings AS
SELECT
    t.id AS team_id,
    t.name AS team_name,
    t.division_id,
    d.name AS division_name,
    d.league_id,
    COUNT(DISTINCT m.id) AS played,
    SUM(CASE
        WHEN (m.home_team_id = t.id AND m.home_score > m.away_score) OR
             (m.away_team_id = t.id AND m.away_score > m.home_score)
        THEN 1 ELSE 0
    END) AS wins,
    SUM(CASE
        WHEN m.status = 'completed' AND m.home_score = m.away_score
        THEN 1 ELSE 0
    END) AS draws,
    SUM(CASE
        WHEN (m.home_team_id = t.id AND m.home_score < m.away_score) OR
             (m.away_team_id = t.id AND m.away_score < m.home_score)
        THEN 1 ELSE 0
    END) AS losses,
    SUM(CASE
        WHEN m.home_team_id = t.id THEN m.home_score
        WHEN m.away_team_id = t.id THEN m.away_score
        ELSE 0
    END) AS goals_for,
    SUM(CASE
        WHEN m.home_team_id = t.id THEN m.away_score
        WHEN m.away_team_id = t.id THEN m.home_score
        ELSE 0
    END) AS goals_against,
    (SUM(CASE
        WHEN m.home_team_id = t.id THEN m.home_score
        WHEN m.away_team_id = t.id THEN m.away_score
        ELSE 0
    END) - SUM(CASE
        WHEN m.home_team_id = t.id THEN m.away_score
        WHEN m.away_team_id = t.id THEN m.home_score
        ELSE 0
    END)) AS goal_difference,
    (SUM(CASE
        WHEN (m.home_team_id = t.id AND m.home_score > m.away_score) OR
             (m.away_team_id = t.id AND m.away_score > m.home_score)
        THEN 3
        WHEN m.status = 'completed' AND m.home_score = m.away_score
        THEN 1
        ELSE 0
    END)) AS points
FROM teams t
LEFT JOIN matches m ON (m.home_team_id = t.id OR m.away_team_id = t.id) AND m.status = 'completed'
LEFT JOIN divisions d ON t.division_id = d.id
WHERE t.division_id IS NOT NULL
GROUP BY t.id, t.name, t.division_id, d.name, d.league_id
ORDER BY points DESC, goal_difference DESC, goals_for DESC;

-- =====================================================
-- 6. PLAYER STATISTICS (Calculated View)
-- =====================================================

CREATE OR REPLACE VIEW player_stats AS
SELECT
    p.id AS player_id,
    p.full_name,
    p.team_id,
    t.name AS team_name,
    p.position,
    COUNT(DISTINCT CASE WHEN me.event_type IN ('goal', 'penalty') THEN m.id END) AS matches_played,
    COUNT(CASE WHEN me.event_type = 'goal' THEN 1 END) AS goals,
    COUNT(CASE WHEN me.event_type = 'penalty' THEN 1 END) AS penalties,
    COUNT(CASE WHEN me.event_type = 'yellow_card' THEN 1 END) AS yellow_cards,
    COUNT(CASE WHEN me.event_type = 'red_card' THEN 1 END) AS red_cards
FROM players p
LEFT JOIN match_events me ON p.id = me.player_id
LEFT JOIN matches m ON me.match_id = m.id AND m.status = 'completed'
LEFT JOIN teams t ON p.team_id = t.id
GROUP BY p.id, p.full_name, p.team_id, t.name, p.position;

-- =====================================================
-- 7. FAN ENGAGEMENT
-- =====================================================

-- Fan votes table (for player of the week, etc.)
CREATE TABLE fan_votes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id),
    player_id UUID REFERENCES players(id),
    vote_category TEXT NOT NULL, -- 'player_of_week', 'goal_of_week', etc.
    week_number INTEGER NOT NULL,
    season_year INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, vote_category, week_number, season_year)
);

ALTER TABLE fan_votes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Fans can vote" ON fan_votes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Everyone can view votes" ON fan_votes
    FOR SELECT USING (true);

-- Announcements table
CREATE TABLE announcements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    league_id UUID REFERENCES leagues(id),
    division_id UUID REFERENCES divisions(id),
    is_published BOOLEAN DEFAULT false,
    published_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Published announcements are viewable by everyone" ON announcements
    FOR SELECT USING (is_published = true);

CREATE POLICY "Admins can manage announcements" ON announcements
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- 8. TRIGGERS & FUNCTIONS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to all relevant tables
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_leagues_updated_at BEFORE UPDATE ON leagues
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_divisions_updated_at BEFORE UPDATE ON divisions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON announcements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'fan')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call handle_new_user on signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- 9. INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_matches_division_id ON matches(division_id);
CREATE INDEX idx_matches_home_team ON matches(home_team_id);
CREATE INDEX idx_matches_away_team ON matches(away_team_id);
CREATE INDEX idx_matches_date ON matches(match_date);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_match_events_match_id ON match_events(match_id);
CREATE INDEX idx_match_events_player_id ON match_events(player_id);
CREATE INDEX idx_players_team_id ON players(team_id);
CREATE INDEX idx_teams_division_id ON teams(division_id);
CREATE INDEX idx_divisions_league_id ON divisions(league_id);
CREATE INDEX idx_profiles_role ON profiles(role);
