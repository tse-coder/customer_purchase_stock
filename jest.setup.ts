import '@testing-library/jest-dom'
import { TextEncoder, TextDecoder } from 'util'

global.TextEncoder = TextEncoder as any
global.TextDecoder = TextDecoder as any

// If Request/Response/Fetch are missing (older Node versions), polyfill them
if (!global.Request) {
    const { Request, Response, Headers, fetch } = require('undici')
    global.Request = Request
    global.Response = Response
    global.Headers = Headers
    global.fetch = fetch
}
