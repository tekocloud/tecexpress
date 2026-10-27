import { afterEach, describe, expect, it, vi } from 'vitest'
import { txHttpUpload } from '../src'
class Request {
  static sent: FormData[] = []
  static failAt = -1
  upload: {
    onprogress?: (e: {
      lengthComputable: boolean
      loaded: number
      total: number
    }) => void
  } = {}
  status = 200
  statusText = 'OK'
  responseText = 'done'
  withCredentials = false
  onload?: () => void
  onerror?: () => void
  onabort?: () => void
  aborted = false
  open() {}
  setRequestHeader() {}
  abort() {
    this.aborted = true
    this.onabort?.()
  }
  send(form: FormData) {
    const index = Request.sent.push(form) - 1
    queueMicrotask(() => {
      if (this.aborted) return
      if (index === Request.failAt) this.status = 500
      this.upload.onprogress?.({
        lengthComputable: true,
        loaded: 10,
        total: 10,
      })
      this.onload?.()
    })
  }
}
afterEach(() => {
  vi.unstubAllGlobals()
  Request.sent = []
  Request.failAt = -1
})
describe('HTTP upload adapter', () => {
  it('sends deterministic chunks with protocol fields and reports file progress', async () => {
    vi.stubGlobal('XMLHttpRequest', Request)
    const onProgress = vi.fn(),
      adapter = txHttpUpload({
        url: '/upload',
        chunkSize: 2,
        fields: { folder: 'docs' },
        chunkFields: (_, index, count) => ({
          index: String(index),
          count: String(count),
        }),
      })
    expect(
      await adapter(new File(['hello'], 'hello.txt'), {
        signal: new AbortController().signal,
        onProgress,
      }),
    ).toBe('done')
    expect(Request.sent.map((v) => (v.get('file') as Blob).size)).toEqual([
      2, 2, 1,
    ])
    expect(Request.sent.map((v) => v.get('index'))).toEqual(['0', '1', '2'])
    expect(Request.sent[2].get('count')).toBe('3')
    expect(Request.sent[0].get('folder')).toBe('docs')
    expect(onProgress).toHaveBeenLastCalledWith(5, 5)
  })
  it('stops at a failed chunk and starts at the first chunk when retried', async () => {
    vi.stubGlobal('XMLHttpRequest', Request)
    Request.failAt = 0
    const adapter = txHttpUpload({ url: '/upload', chunkSize: 2 }),
      file = new File(['hello'], 'hello.txt'),
      context = { signal: new AbortController().signal, onProgress: vi.fn() }
    await expect(adapter(file, context)).rejects.toThrow('HTTP 500')
    expect(Request.sent).toHaveLength(1)
    await adapter(file, context)
    expect(Request.sent).toHaveLength(4)
  })
  it('aborts the in-flight request and rejects invalid chunk configurations', async () => {
    vi.stubGlobal('XMLHttpRequest', Request)
    const controller = new AbortController(),
      file = new File(['hello'], 'hello.txt'),
      pending = txHttpUpload({ url: '/upload', chunkSize: 2 })(file, {
        signal: controller.signal,
        onProgress() {},
      })
    controller.abort()
    await expect(pending).rejects.toMatchObject({ name: 'AbortError' })
    expect(Request.sent).toHaveLength(1)
    await expect(
      txHttpUpload({ url: '/upload', chunkSize: 0 })(file, {
        signal: new AbortController().signal,
        onProgress() {},
      }),
    ).rejects.toThrow('positive')
  })
})
