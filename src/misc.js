var x = require('./grammar');

var wrap = function(scope) {
    return function() {
        return this.textValue;
    };
};

x.Parser.Space   = { name: 'Space',   eval: wrap };
x.Parser.Paren   = { name: 'Paren',   eval: wrap };
x.Parser.Bracket = { name: 'Bracket', eval: wrap };
x.Parser.Delim   = { name: 'Delim',   eval: wrap };


