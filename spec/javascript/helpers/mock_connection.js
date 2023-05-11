const ConnectionMock = {
  request:   () => ({ json: async () => {} }),
  serverURL: 'http://mockURL:3000'
};

export default ConnectionMock;
