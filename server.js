// A simple static file server for development use.
var express = require('express');
var app = express();
app.use('/', express.static(__dirname));
app.listen('3001');
console.log("Server listening on http://localhost:3001");
