// Database types for Liberia League Management App

export type UserRole = 'admin' | 'team_manager' | 'match_official' | 'player' | 'fan'
export type SportType = 'football' | 'basketball' | 'volleyball'
export type PlayerPosition = 'goalkeeper' | 'defender' | 'midfielder' | 'forward' | 'substitute'
export type MatchStatus = 'scheduled' | 'live' | 'completed' | 'postponed' | 'cancelled'
export type EventType = 'goal' | 'yellow_card' | 'red_card' | 'substitution' | 'penalty' | 'own_goal'

export interface Profile {
  id: string
  email: string
  full_name: string
  role: UserRole
  avatar_url?: string
  phone?: string
  created_at: string
  updated_at: string
}

export interface League {
  id: string
  name: string
  sport: SportType
  description?: string
  season_start_date: string
  season_end_date: string
  logo_url?: string
  is_active: boolean
  created_by?: string
  created_at: string
  updated_at: string
}

export interface Division {
  id: string
  league_id: string
  name: string
  description?: string
  tier: number
  max_teams: number
  promotion_spots: number
  relegation_spots: number
  created_at: string
  updated_at: string
}

export interface Team {
  id: string
  name: string
  short_name?: string
  logo_url?: string
  home_city?: string
  home_venue?: string
  founded_year?: number
  manager_id?: string
  division_id?: string
  created_at: string
  updated_at: string
}

export interface Player {
  id: string
  user_id?: string
  team_id?: string
  full_name: string
  jersey_number?: number
  position?: PlayerPosition
  date_of_birth?: string
  nationality: string
  height_cm?: number
  weight_kg?: number
  photo_url?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Match {
  id: string
  division_id: string
  round_number: number
  home_team_id: string
  away_team_id: string
  match_date: string
  venue?: string
  referee_id?: string
  status: MatchStatus
  home_score: number
  away_score: number
  attendance?: number
  notes?: string
  created_at: string
  updated_at: string
}

export interface MatchEvent {
  id: string
  match_id: string
  team_id: string
  player_id: string
  event_type: EventType
  minute: number
  extra_time_minute: number
  description?: string
  created_at: string
}

export interface DivisionStanding {
  team_id: string
  team_name: string
  division_id: string
  division_name: string
  league_id: string
  played: number
  wins: number
  draws: number
  losses: number
  goals_for: number
  goals_against: number
  goal_difference: number
  points: number
}

export interface PlayerStats {
  player_id: string
  full_name: string
  team_id: string
  team_name: string
  position?: PlayerPosition
  matches_played: number
  goals: number
  penalties: number
  yellow_cards: number
  red_cards: number
}

export interface FanVote {
  id: string
  user_id: string
  player_id: string
  vote_category: string
  week_number: number
  season_year: number
  created_at: string
}

export interface Announcement {
  id: string
  title: string
  content: string
  league_id?: string
  division_id?: string
  is_published: boolean
  published_at?: string
  created_by: string
  created_at: string
  updated_at: string
}

// Extended types with relations
export interface MatchWithTeams extends Match {
  home_team: Team
  away_team: Team
  referee?: Profile
  division: Division
}

export interface PlayerWithTeam extends Player {
  team?: Team
}

export interface TeamWithPlayers extends Team {
  players: Player[]
  manager?: Profile
}

export interface DivisionWithTeams extends Division {
  teams: Team[]
  league: League
}

export interface DivisionWithLeague extends Division {
  league: { name: string }
}

export interface TeamWithDivision extends Team {
  division: {
    name: string
    league: { name: string }
  }
}
