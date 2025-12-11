import { createClient } from '@/lib/supabase/server'
import Link from 'next/link'

export default async function TeamsPage() {
  const supabase = await createClient()

  // Fetch league teams with division and league information
  const { data: leagueTeams } = await supabase
    .from('teams')
    .select(`
      *,
      division:divisions (
        id,
        name,
        league:leagues (
          name
        )
      ),
      _count:players(count)
    `)
    .order('name')

  // Fetch cup teams
  const { data: cupTeams } = await supabase
    .from('cup_teams_registry')
    .select(`
      *,
      cup:cups (
        id,
        name
      )
    `)
    .order('name')

  // Combine and format both types of teams
  const allTeams = [
    ...(leagueTeams || []).map(team => ({
      ...team,
      type: 'league' as const,
      competitionName: team.division?.league?.name || 'Unknown League',
      competitionType: team.division?.name || 'Unknown Division'
    })),
    ...(cupTeams || []).map(team => ({
      ...team,
      type: 'cup' as const,
      competitionName: team.cup?.name || 'Unknown Cup',
      competitionType: 'Cup Competition'
    }))
  ].sort((a, b) => a.name.localeCompare(b.name))

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-r from-liberia-blue to-liberia-blue-dark text-white py-12">
        <div className="container mx-auto px-4">
          <h1 className="text-4xl font-bold mb-2">Teams</h1>
          <p className="text-blue-100">All registered teams across divisions</p>
        </div>
      </div>

      <div className="container mx-auto px-4 py-8">
        {allTeams && allTeams.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {allTeams.map((team) => (
              <Link
                key={team.id}
                href={`/teams/${team.id}`}
                className="bg-white rounded-lg shadow hover:shadow-lg transition p-6 group"
              >
                {/* Team Logo */}
                <div className="flex items-center mb-4">
                  <div className="w-16 h-16 bg-gray-200 rounded-full mr-4 flex items-center justify-center overflow-hidden">
                    {team.logo_url ? (
                      <img
                        src={team.logo_url}
                        alt={team.name}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <span className="text-2xl">⚽</span>
                    )}
                  </div>
                  <div className="flex-1">
                    <h3 className="font-bold text-lg group-hover:text-liberia-red transition">
                      {team.name}
                    </h3>
                    {team.short_name && (
                      <p className="text-sm text-gray-500">{team.short_name}</p>
                    )}
                  </div>
                </div>

                {/* Team Info */}
                <div className="space-y-2 text-sm">
                  <div className="flex items-center text-gray-600">
                    <span className="mr-2">{team.type === 'cup' ? '🏆' : '📊'}</span>
                    <span>
                      {team.competitionName}
                      {team.type === 'league' && ` - ${team.competitionType}`}
                    </span>
                  </div>
                  {team.home_city && (
                    <div className="flex items-center text-gray-600">
                      <span className="mr-2">📍</span>
                      <span>{team.home_city}</span>
                    </div>
                  )}
                  {team.home_venue && (
                    <div className="flex items-center text-gray-600">
                      <span className="mr-2">🏟️</span>
                      <span>{team.home_venue}</span>
                    </div>
                  )}
                  {team.founded_year && (
                    <div className="flex items-center text-gray-600">
                      <span className="mr-2">📅</span>
                      <span>Founded {team.founded_year}</span>
                    </div>
                  )}
                </div>

                {/* View Details Button */}
                <div className="mt-4 pt-4 border-t">
                  <span className="text-liberia-red group-hover:text-liberia-blue font-medium text-sm">
                    View Team Details →
                  </span>
                </div>
              </Link>
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow p-12 text-center">
            <div className="text-gray-400 text-6xl mb-4">👥</div>
            <h3 className="text-2xl font-bold text-gray-700 mb-2">No Teams Yet</h3>
            <p className="text-gray-600 mb-6">
              Teams will appear here once they are registered
            </p>
          </div>
        )}
      </div>
    </div>
  )
}
