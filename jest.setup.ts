import '@testing-library/jest-dom'
import { TextEncoder, TextDecoder } from 'util'

global.TextEncoder = TextEncoder as any
global.TextDecoder = TextDecoder as any

// Node 18+ has these on globalThis, but JSDOM environment might hide them
if (typeof global.Request === 'undefined') {
    global.Request = globalThis.Request
}
if (typeof global.Response === 'undefined') {
    global.Response = globalThis.Response
}
if (typeof global.Headers === 'undefined') {
    global.Headers = globalThis.Headers
}
if (typeof global.fetch === 'undefined') {
    global.fetch = globalThis.fetch
}
if (typeof global.ReadableStream === 'undefined') {
    global.ReadableStream = globalThis.ReadableStream
}
if (typeof global.WritableStream === 'undefined') {
    global.WritableStream = globalThis.WritableStream
}
if (typeof global.TransformStream === 'undefined') {
    global.TransformStream = globalThis.TransformStream
}
