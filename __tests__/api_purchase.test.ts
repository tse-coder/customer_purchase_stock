import { NextRequest } from 'next/server'
import { POST } from '../app/api/purchase/route'
import { purchase } from '../app/actions/purchase'

// Mock the purchase action
jest.mock('../app/actions/purchase', () => ({
    purchase: jest.fn(),
}))

describe('POST /api/purchase', () => {
    it('should return 200 and success:true on successful purchase', async () => {
        const mockBody = {
            business_id: 'b1',
            customer_id: 'c1',
            items: [{ product_id: 'p1', quantity: 1 }],
        }

        const req = new NextRequest('http://localhost:3000/api/purchase', {
            method: 'POST',
            body: JSON.stringify(mockBody),
        })

            ; (purchase as jest.Mock).mockResolvedValue({ success: true })

        const res = await POST(req)
        const data = await res.json()

        expect(res.status).toBe(200)
        expect(data).toEqual({ success: true })
        expect(purchase).toHaveBeenCalledWith(mockBody)
    })

    it('should return 400 and error message on failure', async () => {
        const mockBody = {
            business_id: 'b1',
            customer_id: 'c1',
            items: [{ product_id: 'p1', quantity: 1 }],
        }

        const req = new NextRequest('http://localhost:3000/api/purchase', {
            method: 'POST',
            body: JSON.stringify(mockBody),
        })

        const errorMessage = 'Out of stock'
            ; (purchase as jest.Mock).mockRejectedValue(new Error(errorMessage))

        const res = await POST(req)
        const data = await res.json()

        expect(res.status).toBe(400)
        expect(data).toEqual({ error: errorMessage })
    })
})
