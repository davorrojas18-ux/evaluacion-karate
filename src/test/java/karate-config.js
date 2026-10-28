function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    env: env,
    _urlAuth: 'http://134.209.211.10:4001',
    _urlWallet: 'http://134.209.211.10:4002',
    _urlTransaction: 'http://134.209.211.10:4003'
  }
  return config;
}