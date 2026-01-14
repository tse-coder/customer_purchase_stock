import { NextRequest, NextResponse } from 'next/server'
import { purchase } from '@/app/actions/purchase'

export async function POST(req: NextRequest) {
  try {
    const body = await req.json()

    await purchase(body)

    return NextResponse.json({ success: true })
  } catch (err: any) {
    return NextResponse.json(
      { error: err.message },
      { status: 400 }
    )
  }
}
