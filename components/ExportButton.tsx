'use client'

import { exportStandingsToCSV } from '@/lib/utils/export'

type ExportButtonProps = {
  data: any[]
  divisionName: string
  type?: 'standings' | 'fixtures' | 'players'
}

export default function ExportButton({ data, divisionName, type = 'standings' }: ExportButtonProps) {
  const handleExport = () => {
    if (type === 'standings') {
      exportStandingsToCSV(data, divisionName)
    }
    // Can add other export types here
  }

  return (
    <button
      onClick={handleExport}
      className="bg-liberia-red hover:bg-liberia-blue text-white font-bold py-2 px-4 rounded transition text-sm"
    >
      📥 Export CSV
    </button>
  )
}
