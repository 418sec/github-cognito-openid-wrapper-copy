const JSONWebKey = require('json-web-key');
const jwt = require('jsonwebtoken');
const { GITHUB_CLIENT_ID } = require('./config');
const logger = require('./connectors/logger');

const KEY_ID = 'jwtRS256';
const cert = process.env.JWT_RS256_KEY;
const pubKey = process.env.JWT_RS256_PUBLIC_KEY;

module.exports = {
  getPublicKey: () => ({
    alg: 'RS256',
    kid: KEY_ID,
    ...JSONWebKey.fromPEM(pubKey).toJSON(),
  }),

  makeIdToken: (payload, host) => {
    const enrichedPayload = {
      ...payload,
      iss: `https://${host}`,
      aud: GITHUB_CLIENT_ID,
    };
    logger.debug('Signing payload %j', enrichedPayload, {});
    return jwt.sign(enrichedPayload, cert, {
      expiresIn: '1h',
      algorithm: 'RS256',
      keyid: KEY_ID,
    });
  },
};
