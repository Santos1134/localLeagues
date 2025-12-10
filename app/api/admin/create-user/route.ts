import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const { email, password, full_name, role, managed_league_id, managed_cup_id, user_id } = body

    // Validate required fields
    if (!user_id) {
      return NextResponse.json(
        { error: 'User ID is required' },
        { status: 400 }
      )
    }

    // Create admin client with service role key (bypasses RLS)
    const supabaseAdmin = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    // Insert or update the profile with admin role and permissions using service role (bypasses RLS)
    const { error: profileError } = await supabaseAdmin
      .from('profiles')
      .upsert({
        id: user_id,
        email: email.trim().toLowerCase(),
        role: role || 'league_admin',
        managed_league_id: managed_league_id || null,
        managed_cup_id: managed_cup_id || null,
        full_name: full_name || null
      }, {
        onConflict: 'id'
      })

    if (profileError) {
      console.error('Profile update error:', profileError)
      return NextResponse.json(
        { error: `Profile update failed: ${profileError.message}` },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      user: {
        id: user_id,
        email: email
      }
    })

  } catch (error: any) {
    console.error('Unexpected error:', error)
    return NextResponse.json(
      { error: error.message || 'Internal server error' },
      { status: 500 }
    )
  }
}
