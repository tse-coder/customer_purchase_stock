'use server'

import { supabase } from '@/lib/supabase'

export async function purchase(input: {
  business_id: string
  customer_id: string
  items: { product_id: string; quantity: number }[]
}) {
  const { error } = await supabase.rpc('process_purchase', {
    p_business_id: input.business_id,
    p_customer_id: input.customer_id,
    p_items: input.items
  })

  if (error) {
    throw new Error(error.message)
  }

  return { success: true }
}
