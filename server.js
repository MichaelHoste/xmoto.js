// A simple static file server for development use.
var express = require('express');
var csrf = require('csrf');
var app = express();
var tokens = new csrf();
app.use(function(req, res, next) {
  if (['GET', 'HEAD', 'OPTIONS'].indexOf(req.method) !== -1) return next();
  var secret = req.headers['x-csrf-secret'] || '';
  var token = req.headers['x-csrf-token'] || '';
  if (!tokens.verify(secret, token)) {
    return res.status(403).send('Invalid CSRF token');
  }
  next();
});
app.use('/', express.static(__dirname));
app.listen('3001');
console.log("Server listening on http://localhost:3001");
