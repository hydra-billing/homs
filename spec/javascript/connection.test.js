import Connection from 'hbw/connection';

describe('Connection', () => {
  const buildConnection = () => new Connection({
    host:    'http://example.com',
    path:    '/widget',
    payload: { variables: {} }
  });

  beforeEach(() => {
    global.fetch = jest.fn().mockResolvedValue({ ok: true });
  });

  afterEach(() => {
    document.head.innerHTML = '';
  });

  describe('mutating requests', () => {
    test('sends the CSRF token from the page meta tag', () => {
      document.head.innerHTML = '<meta name="csrf-token" content="token-from-meta">';

      buildConnection().request({ url: 'http://example.com/widget/buttons', method: 'POST', data: {} });

      const [, opts] = global.fetch.mock.calls[0];
      expect(opts.headers['X-CSRF-Token']).toEqual('token-from-meta');
    });

    test('prefers a caller-provided CSRF token over the meta tag one', () => {
      document.head.innerHTML = '<meta name="csrf-token" content="token-from-meta">';

      buildConnection().request({
        url:     'http://example.com/widget/tasks/42/form',
        method:  'PUT',
        data:    {},
        headers: { 'X-CSRF-Token': 'token-from-form' }
      });

      const [, opts] = global.fetch.mock.calls[0];
      expect(opts.headers['X-CSRF-Token']).toEqual('token-from-form');
    });

    test('sends no CSRF token when the page has no meta tag', () => {
      buildConnection().request({ url: 'http://example.com/widget/buttons', method: 'POST', data: {} });

      const [, opts] = global.fetch.mock.calls[0];
      expect(opts.headers['X-CSRF-Token']).toBeUndefined();
    });
  });

  describe('GET requests', () => {
    test('passes data and payload as query parameters', () => {
      buildConnection().request({ url: 'http://example.com/widget/buttons', method: 'GET', data: { a: '1' } });

      const [url] = global.fetch.mock.calls[0];
      expect(url).toContain('a=1');
    });
  });
});
