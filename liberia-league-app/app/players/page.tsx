import { createClient } from '@/lib/supabase/server'

export default async function PlayersPage() {
  const supabase = await createClient()

  // Fetch player statistics
  const { data: topScorers } = await supabase
    .from('player_stats')
    .select('*')
    .order('goals', { ascending: false })
    .limit(20)

  // Fetch all players
  const { data: players } = await supabase
    .from('players')
    .select(`
      *,
      team:teams (
        id,
        name,
        logo_url
      )
    `)
    .eq('is_active', true)
    .order('full_name')

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-r from-liberia-blue to-liberia-blue-dark text-white py-12">
        <div className="container mx-auto px-4">
          <h1 className="text-4xl font-bold mb-2">Players</h1>
          <p className="text-blue-100">Statistics and profiles</p>
        </div>
      </div>

      <div className="container mx-auto px-4 py-8">
        {/* Top Scorers Section */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold mb-4">Top Scorers</h2>
          {topScorers && topScorers.length > 0 ? (
            <div className="bg-white rounded-lg shadow overflow-hidden">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Rank
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Player
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Team
                    </th>
                    <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Goals
                    </th>
                    <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Matches
                    </th>
                    <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Yellow Cards
                    </th>
                    <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Red Cards
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {topScorers.map((player, index) => (
                    <tr key={player.player_id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          {index < 3 && (
                            <span className="text-2xl mr-2">
                              {index === 0 ? '🥇' : index === 1 ? '🥈' : '🥉'}
                            </span>
                          )}
                          <span className="text-sm font-medium text-gray-900">
                            {index + 1}
                          </span>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">
                          {player.full_name}
                        </div>
                        <div className="text-sm text-gray-500 capitalize">
                          {player.position}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {player.team_name || 'Free Agent'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-center">
                        <span className="text-lg font-bold text-liberia-red">
                          {player.goals}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-center text-sm text-gray-500">
                        {player.matches_played}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-center text-sm text-yellow-600">
                        {player.yellow_cards}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-center text-sm text-red-600">
                        {player.red_cards}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="bg-white rounded-lg shadow p-8 text-center">
              <div className="text-gray-400 text-5xl mb-4">🏆</div>
              <h3 className="text-xl font-bold text-gray-700 mb-2">No Statistics Yet</h3>
              <p className="text-gray-600">
                Player statistics will appear here after matches are played
              </p>
            </div>
          )}
        </div>

        {/* All Players Section */}
        <div>
          <h2 className="text-2xl font-bold mb-4">All Players</h2>
          {players && players.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {players.map((player) => (
                <div key={player.id} className="bg-white rounded-lg shadow p-6">
                  <div className="flex items-center mb-4">
                    <div className="w-12 h-12 bg-gray-200 rounded-full mr-4 flex items-center justify-center overflow-hidden">
                      {player.photo_url ? (
                        <img
                          src={player.photo_url}
                          alt={player.full_name}
                          className="w-full h-full object-cover"
                        />
                      ) : (
                        <span className="text-xl">👤</span>
                      )}
                    </div>
                    <div>
                      <h3 className="font-bold">{player.full_name}</h3>
                      {player.jersey_number && (
                        <p className="text-sm text-gray-500">#{player.jersey_number}</p>
                      )}
                    </div>
                  </div>

                  <div className="space-y-2 text-sm">
                    {player.position && (
                      <div className="flex justify-between">
                        <span className="text-gray-600">Position:</span>
                        <span className="font-medium capitalize">{player.position}</span>
                      </div>
                    )}
                    {player.team && (
                      <div className="flex justify-between">
                        <span className="text-gray-600">Team:</span>
                        <span className="font-medium">{(player.team as any).name}</span>
                      </div>
                    )}
                    {player.nationality && (
                      <div className="flex justify-between">
                        <span className="text-gray-600">Nationality:</span>
                        <span className="font-medium">{player.nationality}</span>
                      </div>
                    )}
                    {player.date_of_birth && (
                      <div className="flex justify-between">
                        <span className="text-gray-600">Age:</span>
                        <span className="font-medium">
                          {new Date().getFullYear() -
                            new Date(player.date_of_birth).getFullYear()}
                        </span>
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="bg-white rounded-lg shadow p-12 text-center">
              <div className="text-gray-400 text-6xl mb-4">👥</div>
              <h3 className="text-2xl font-bold text-gray-700 mb-2">No Players Yet</h3>
              <p className="text-gray-600">Players will appear here once they are registered</p>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
