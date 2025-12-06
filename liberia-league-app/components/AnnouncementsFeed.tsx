'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'

type Announcement = {
  id: string
  title: string
  content: string
  priority: 'low' | 'medium' | 'high'
  published_at: string
  league?: { name: string }
}

export default function AnnouncementsFeed() {
  const supabase = createClient()
  const [announcements, setAnnouncements] = useState<Announcement[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchAnnouncements()
  }, [])

  const fetchAnnouncements = async () => {
    const { data } = await supabase
      .from('announcements')
      .select('*, league:leagues(name)')
      .eq('is_published', true)
      .order('published_at', { ascending: false })
      .limit(5)

    if (data) setAnnouncements(data)
    setLoading(false)
  }

  const getPriorityIcon = (priority: string) => {
    switch (priority) {
      case 'high': return '🔴'
      case 'medium': return '🟡'
      case 'low': return '🔵'
      default: return '📢'
    }
  }

  if (loading) {
    return (
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-2xl font-bold mb-4 text-liberia-blue">Latest News</h2>
        <div className="text-center text-gray-500">Loading...</div>
      </div>
    )
  }

  if (announcements.length === 0) {
    return null
  }

  return (
    <div className="bg-white rounded-lg shadow overflow-hidden">
      <div className="bg-gradient-to-r from-liberia-blue to-liberia-blue-dark text-white px-6 py-4">
        <h2 className="text-2xl font-bold">📢 Latest News</h2>
      </div>
      <div className="divide-y">
        {announcements.map((announcement) => (
          <div key={announcement.id} className="p-6 hover:bg-gray-50 transition">
            <div className="flex items-start gap-3">
              <span className="text-2xl">{getPriorityIcon(announcement.priority)}</span>
              <div className="flex-1">
                <h3 className="font-bold text-lg text-gray-900 mb-1">{announcement.title}</h3>
                <p className="text-gray-700 mb-2">{announcement.content}</p>
                <div className="flex items-center gap-4 text-sm text-gray-500">
                  <span>{announcement.league?.name || 'All Leagues'}</span>
                  <span>•</span>
                  <span>{new Date(announcement.published_at).toLocaleDateString()}</span>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
