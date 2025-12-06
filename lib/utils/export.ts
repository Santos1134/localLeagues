// Utility functions for exporting data

export function exportToCSV(data: any[], filename: string) {
  if (data.length === 0) {
    alert('No data to export')
    return
  }

  // Get headers from first object
  const headers = Object.keys(data[0])

  // Create CSV content
  let csv = headers.join(',') + '\n'

  data.forEach(row => {
    const values = headers.map(header => {
      const value = row[header]
      // Handle values that might contain commas or quotes
      if (value === null || value === undefined) return ''
      const stringValue = String(value)
      if (stringValue.includes(',') || stringValue.includes('"') || stringValue.includes('\n')) {
        return `"${stringValue.replace(/"/g, '""')}"`
      }
      return stringValue
    })
    csv += values.join(',') + '\n'
  })

  // Create download link
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)

  link.setAttribute('href', url)
  link.setAttribute('download', `${filename}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

export function exportStandingsToCSV(standings: any[], divisionName: string) {
  const exportData = standings.map(team => ({
    Position: team.position,
    Team: team.team_name,
    'Matches Played': team.matches_played,
    Won: team.wins,
    Drawn: team.draws,
    Lost: team.losses,
    'Goals For': team.goals_for,
    'Goals Against': team.goals_against,
    'Goal Difference': team.goal_difference,
    Points: team.points,
  }))

  exportToCSV(exportData, `${divisionName.replace(/\s+/g, '_')}_Standings_${new Date().toISOString().split('T')[0]}`)
}

export function exportPlayersToCSV(players: any[]) {
  const exportData = players.map(player => ({
    Name: player.full_name,
    'Jersey Number': player.jersey_number,
    Position: player.position,
    Team: player.team?.name || '',
    Goals: player.goals || 0,
    'Yellow Cards': player.yellow_cards || 0,
    'Red Cards': player.red_cards || 0,
  }))

  exportToCSV(exportData, `Players_${new Date().toISOString().split('T')[0]}`)
}

export function exportMatchesToCSV(matches: any[], divisionName: string) {
  const exportData = matches.map(match => ({
    Date: new Date(match.match_date).toLocaleDateString(),
    Time: match.match_time || '',
    'Home Team': match.home_team?.name || '',
    'Away Team': match.away_team?.name || '',
    Score: match.home_score !== null ? `${match.home_score} - ${match.away_score}` : 'Not played',
    Status: match.status,
    Venue: match.venue || '',
    Round: match.round_number || '',
  }))

  exportToCSV(exportData, `${divisionName.replace(/\s+/g, '_')}_Fixtures_${new Date().toISOString().split('T')[0]}`)
}
