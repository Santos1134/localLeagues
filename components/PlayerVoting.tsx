'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'

type PlayerVotingProps = {
  playerId: string
  playerName: string
  currentVotes: number
}

export default function PlayerVoting({ playerId, playerName, currentVotes }: PlayerVotingProps) {
  const supabase = createClient()
  const [votes, setVotes] = useState(currentVotes)
  const [hasVoted, setHasVoted] = useState(false)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    checkIfVoted()
  }, [])

  const checkIfVoted = async () => {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data } = await supabase
      .from('fan_votes')
      .select('*')
      .eq('fan_id', user.id)
      .eq('player_id', playerId)
      .single()

    if (data) setHasVoted(true)
  }

  const handleVote = async () => {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      alert('Please log in to vote')
      return
    }

    setLoading(true)

    const { error } = await supabase
      .from('fan_votes')
      .insert({
        fan_id: user.id,
        player_id: playerId,
      })

    if (error) {
      if (error.message.includes('duplicate') || error.code === '23505') {
        alert('You have already voted for this player')
      } else {
        alert('Error voting: ' + error.message)
      }
    } else {
      setVotes(votes + 1)
      setHasVoted(true)
    }

    setLoading(false)
  }

  return (
    <button
      onClick={handleVote}
      disabled={hasVoted || loading}
      className={`flex items-center gap-2 px-4 py-2 rounded font-semibold transition ${
        hasVoted
          ? 'bg-gray-300 text-gray-600 cursor-not-allowed'
          : 'bg-liberia-red hover:bg-liberia-blue text-white'
      }`}
    >
      <span>⭐</span>
      <span>{hasVoted ? 'Voted' : 'Vote'}</span>
      <span className="ml-1 text-sm">({votes})</span>
    </button>
  )
}
