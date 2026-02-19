import { purchase } from '../app/actions/purchase'
import { supabase } from '../lib/supabase'

// Mock Supabase client
jest.mock('../lib/supabase', () => ({
    supabase: {
        rpc: jest.fn(),
    },
}))

describe('purchase action', () => {
    it('should call supabase rpc with correct parameters', async () => {
        const mockInput = {
            business_id: 'b1',
            customer_id: 'c1',
            items: [{ product_id: 'p1', quantity: 2 }],
        }

            ; (supabase.rpc as jest.Mock).mockResolvedValue({ data: null, error: null })

        const result = await purchase(mockInput)

        expect(supabase.rpc).toHaveBeenCalledWith('process_purchase', {
            p_business_id: mockInput.business_id,
            p_customer_id: mockInput.customer_id,
            p_items: mockInput.items,
        })
        expect(result).toEqual({ success: true })
    })

    it('should throw an error if supabase rpc returns an error', async () => {
        const mockInput = {
            business_id: 'b1',
            customer_id: 'c1',
            items: [{ product_id: 'p1', quantity: 2 }],
        }

        const errorMessage = 'insufficient stock'
            ; (supabase.rpc as jest.Mock).mockResolvedValue({
                data: null,
                error: { message: errorMessage }
            })

        await expect(purchase(mockInput)).rejects.toThrow(errorMessage)
    })
})
