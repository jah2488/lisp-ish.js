#!/usr/bin/env node

var p      = require('./grammar');

p.Parser.Program = {
    name: 'Program',
    eval: function(scope) {
        if (scope === undefined) { scope = {} }
        var cells = this.elements;
        var value;
        scope.fns = {};

        for (var i = 0, n = cells.length; i < n; i++) {
            try {
                var resp = cells[i].eval(scope);
                if (resp !== null && resp !== undefined && resp !== NaN) {
                    value = resp; // Only return the last expression
                }
            } catch (e) {
                console.log(e.stack);
                console.log('Exception Occured Evaluating This Node -> \n', cells[i]);
                console.log(e);
            }
        }

        return value;
    },

    compile: function(scope) {
        var cells = this.elements;
        var value = '';
        scope.fns = {};

        for (var i = 0, n = cells.length; i < n; i++) {
            try {
                var resp = cells[i].compile(scope);
                if (resp !== null && resp !== undefined && resp !== NaN) {
                    if(process.env.DEBUG === 'TRUE') {
                       console.log('RESPONSE: ', resp);
                    }
                    value += resp; // Only return the last expression
                }
            } catch (e) {
                console.log('Stack: ', e.stack);
                console.log('Exception Occured Evaluating This Node -> \n', cells[i]);
            }
        }

        return value;
    }
};

p.Parser.Datum = {
    name: 'Datum',
    eval: function(scope, env) {
        if (env !== undefined && scope[env][this.textValue] !== undefined) {
            return scope[env][this.textValue];
        } else if (scope[this.textValue] !== undefined) {
            return scope[this.textValue];
        } else {
            return this.textValue;
        }
    },
    compile: function(scope, env) {
        return this.textValue;
    }
};
p.Parser.Cell = {
    name: 'Cell',
    eval: function(scope, env) {
        if (this.data.textValue === '+')  { return function(args) { return parseFloat(args[0].eval(scope, env)) +   parseFloat(args[1].eval(scope, env)); } }
        if (this.data.textValue === '-')  { return function(args) { return parseFloat(args[0].eval(scope, env)) -   parseFloat(args[1].eval(scope, env)); } }
        if (this.data.textValue === '*')  { return function(args) { return parseFloat(args[0].eval(scope, env)) *   parseFloat(args[1].eval(scope, env)); } }
        if (this.data.textValue === '/')  { return function(args) { return parseFloat(args[0].eval(scope, env)) /   parseFloat(args[1].eval(scope, env)); } }
        if (this.data.textValue === '=')  { return function(args) { return parseFloat(args[0].eval(scope, env)) === parseFloat(args[1].eval(scope, env)); } }
        if (this.data.textValue === '>=') { return function(args) { return parseFloat(args[0].eval(scope, env)) >=  parseFloat(args[1].eval(scope, env)); } }
        if (this.data.textValue === '<=') { return function(args) { return parseFloat(args[0].eval(scope, env)) <=  parseFloat(args[1].eval(scope, env)); } }
        if (this.data.textValue === '>')  { return function(args) { return parseFloat(args[0].eval(scope, env)) >   parseFloat(args[1].eval(scope, env)); } }
        if (this.data.textValue === '<')  { return function(args) { return parseFloat(args[0].eval(scope, env)) <   parseFloat(args[1].eval(scope, env)); } }

        if (this.data.textValue === 'if') {
            return function(args) {
                if (args[0].eval(scope, env)) {
                    return args[1].eval(scope, env);
                } else {
                    return args[2].eval(scope, env);
                }
            }
        }

        if (this.data.textValue === 'case') { return function(args) {

            if (args.length % 2 == 0) { throw "Uneven case" }
            if (args.length > 8) { console.log("TOO MANY STATEMENTS IN CASE: IGNORING ALL MATCHES PAST ", args[7].eval(scope, env)); }

            switch (args[0].eval(scope, env)) {
                case args[1].eval(scope, env):
                    return args[2].eval(scope, env); break;
                case args[3].eval(scope, env):
                    return args[4].eval(scope, env); break;
                case args[5].eval(scope, env):
                    return args[6].eval(scope, env); break;
                case args[7].eval(scope, env):
                    return args[8].eval(scope, env); break;
            }
        }}


        if (this.data.textValue == 'def') { return function(args) {
            var resp = args[1].eval(scope, env)
            this[args[0].eval(scope, env)] = resp;
            return resp;
        }}

        if (this.data.textValue == 'defn') { return function(args) {
            var fn_name = args[0].eval(scope, env);
            var _fnargs = args[1].elements[1].elements;
            var fn_args = args[1].data.cells.elements;
            var fn_body = args[2];

            this.fns[fn_name] = function() {
                if (scope[fn_name] === undefined) { scope[fn_name] = { fns: {} }; }

                if (arguments[0].length > 0) {
                    for (var i = 0; i < fn_args.length; i++) {
                        var arg_name = fn_args[i].data.textValue;
                        var arg_val  = arguments[0]['' + i];
                        scope[fn_name][arg_name] = arg_val.eval(scope, env);
                    }
                }

                return fn_body.eval(scope, fn_name); // Pass in full scope not fn scoped scope
            };
            return this.fns[fn_name];
        }}

        if (scope !== undefined && scope.fns[this.data.textValue] !== undefined) {
            var fn_name = this.data.textValue;
            var fn = scope.fns[fn_name];
            return fn;
        }

        return this.data.eval(scope, env);
    },
    compile: function(scope, env) {
        if (this.data.textValue === '+') { return function(args) {
            return '(function(args) { return parseFloat(' + args[0].compile(scope, env) + ') + parseFloat(' + args[1].compile(scope, env) + '); })()';
        }}
        if (this.data.textValue === '-')   { return function(args) {
            return '(function(args) { return parseFloat(' + args[0].compile(scope, env) + ') - parseFloat(' + args[1].compile(scope, env) + '); })()';
        }}
        if (this.data.textValue === '*')   { return function(args) {
            return '(function(args) { return parseFloat(' + args[0].compile(scope, env) + ') * parseFloat(' + args[1].compile(scope, env) + '); })()';
        }}
        if (this.data.textValue === '/')   { return function(args) {
            return '(function(args) { return parseFloat(' + args[0].compile(scope, env) + ') / parseFloat(' + args[1].compile(scope, env) + '); })()';
        }}
        if (this.data.textValue === '=')   { return function(args) {
            return '(function(args) { return parseFloat(' + args[0].compile(scope, env) + ') === parseFloat(' + args[1].compile(scope, env) + '); })()';
        }}
        if (this.data.textValue === '<')   { return function(args) {
            return '(function(args) { return parseFloat(' + args[0].compile(scope, env) + ') < parseFloat(' + args[1].compile(scope, env) + '); })()';
        }}
        if (this.data.textValue === '>')   { return function(args) {
            return '(function(args) { return parseFloat(' + args[0].compile(scope, env) + ') > parseFloat(' + args[1].compile(scope, env) + '); })()';
        }}
        if (this.data.textValue === '<=')  { return function(args) {
            return '(function(args) { return parseFloat(' + args[0].compile(scope, env) + ') <= parseFloat(' + args[1].compile(scope, env) + '); })()';
        }}
        if (this.data.textValue === '>=')  { return function(args) {
            return '(function(args) { return parseFloat(' + args[0].compile(scope, env) + ') >= parseFloat(' + args[1].compile(scope, env) + '); })()';
        }}

        if (this.data.textValue === 'if') { return function(args) {
            var condition = args[0];
            var ifTrue    = args[1];
            var ifFalse   = args[2];
            return 'if (' + condition.compile(scope, env) + ') { ' + ifTrue.compile(scope, env) + ' } else { ' + (ifFalse !== undefined ? ifFalse.compile(scope, env) : null) + ' }';
        }}

        if (this.data.textValue === 'case') { return function(args) {
            var value = '';
            if (args.length % 2 == 0) { throw "Uneven case" }
            if (args.length > 8) { console.log("TOO MANY STATEMENTS IN CASE: IGNORING ALL MATCHES PAST ", args[7].compile(scope, env)); }

            value = 'switch (' + args[0].compile(scope, env) + ') { ';

            for (var i = 1; i <= (args.length - 2); i++) {
                value += ' case ' + args[i].compile(scope, env) + ':' + ' ' + args[i+1].compile(scope, env) + '; break;  ';
            }

            return value + ' }';
        }}

        if (this.data.textValue == 'def') { return function(args) {
            var resp = args[1].compile(scope, env)
            return 'var ' + args[0].compile(scope, env) + ' = ' + resp + '; ';
        }}

        if (this.data.textValue == 'defn') { return function(args) {
            var fn_name = args[0].compile(scope, env);
            var _fnargs = args[1].elements[1].elements;
            var fn_args = args[1].data.cells.elements;
            var fn_body = args[2];

            var arg_names = (function() {
                var names = [];
                for (var i = 0; i < fn_args.length; i++) {
                    var arg_name = fn_args[i].data.textValue;
                    names.push(arg_name);
                }
                return names;
            })();

            var js_fn_name = (function() {
                return fn_name.replace('?','Predicate').replace('-', '_');
            })();

            var final_body = fn_body.compile(scope, fn_name);
            var final_fn = 'function ' + js_fn_name + '(' + arg_names.join(', ') + ') { return ' + final_body + '; } ';

            return final_fn;
        }}

        if (scope !== undefined && scope.fns[this.data.textValue.replace('?','Predicate').replace('-','_')] !== undefined) {
            var fn_name = this.data.textValue.replace('?','Predicate').replace('-','_');
            return fn_name + "('ni');";
        }

        return this.data.compile(scope, env);
    }
};
p.Parser.Boolean = {
    name: 'Boolean',
    eval: function(scope) {
        return this.textValue === 'true';
    },
    compile: function(scope) {
        return this.textValue === 'true';
    }
};
p.Parser.Number = {
    name: 'Number',
    eval: function(scope) {
        return parseFloat(this.textValue);
    },
    compile: function(scope) {
        return parseFloat(this.textValue);
    }
}
p.Parser.String = {
    name: 'String',
    eval: function(scope) {
        return eval(this.textValue);
    },
    compile: function(scope) {
        return this.textValue;
    }
}
p.Parser.Symbol = {
    name: 'Symbol',
    eval: function(scope) {
        return scope.resolve(this.textValue);
    },
    compile: function(scope) {
        return scope.resolve(this.textValue);
    }
};
p.Parser.List = {
    name: 'List',
    eval: function(scope, env) {
        var cells  = this.cells.elements;
        var proc  = cells[0].eval(scope, env);
        return proc.call(scope, cells.slice(1));
    },
    compile: function(scope, env) {
        var cells  = this.cells.elements;
        var proc  = cells[0].compile(scope, env);
        if (!!(proc && proc.constructor && proc.call && proc.apply)) {
            return proc.call(scope, cells.slice(1));
        } else {
            var fn_name = proc.replace('?','Predicate').replace('-','_');
            return fn_name + '(' + cells.slice(1).map(function(c) { return c.compile(scope, env)}).join(', ') + ');';
        }
    }
};
p.Parser.Vector = {
    name: 'Vector',
    eval: function(scope, env) {
        var cells  = this.data.elements;
        var proc   = cells[0].eval(scope, env);
        return proc.call(scope, cells.slice(1));
    },
    compile: function(scope, env) {
        var cells  = this.data.elements;
        var proc   = cells[0].compile(scope, env);
        return proc.call(scope, cells.slice(1));
    }
};

p.Parser.Space   = { name: 'Space',   eval: function(scope) { return function() { return this.textValue }; } };
p.Parser.Paren   = { name: 'Paren',   eval: function(scope) { return function() { return this.textValue }; } };
p.Parser.Bracket = { name: 'Bracket', eval: function(scope) { return function() { return this.textValue }; } };
p.Parser.Delim   = { name: 'Delim',   eval: function(scope) { return function() { return this.textValue }; } };

if (process.argv[0 + 2].match(/run|r|-r|-e/)) {
  console.log(p.parse(process.argv[0 + 3]).eval({}));
}

if (process.argv[0 + 2].match(/compile|c|-c/)) {
  console.log(p.parse(process.argv[0 + 3]).compile({}));
}

if (process.argv[0 + 2].match(/file|f|-f/)) {
    fs = require('fs');
    fs.readFile(process.argv[0 + 3], 'utf8', function (err, _data) {
        data = _data;
        console.log(p.parse(data).compile({}));
    });
}

if (process.argv[0 + 2].match(/test|t|-t/)) {
    var should = require('should');
    var TRU = 'true';
    var FSE = 'false';

    var ADD = '(+ 100 (+ 5 (+ 10 5)))';
    var SUB = '(- 100 (- 50 25))';
    var MLT = '(* 100 (* 2 (* 2 1)))';
    var DIV = '(/ 100 (/ 50 25))';

    var EQL = '(= 100 (+ 50 50))';
    var GTE = '(>= 200 (+ 50 50))';
    var LTE = '(<= 100 (+ 50 50))';
    var GT = '(> 120 (+ 50 50))';
    var LT = '(< 80 (+ 50 50))';

    var IF    = '(if (> 10 0) true)';
    var IFELS = '(if (< 10 0) false true)';

    var CASE = '(case "pick-me" "no" false "pick-me" true 10 false)';
    var CASE_UNEVEN = '(case "pick-me" "no" false "pick-me" true 10)';
    var CASE_MUCH = '(case "pick-me" "no" false "pick-me" true 10 false "no" false "pick-me" true 10 false)';

    var DEF  = '(def yo 100) (+ 100 yo)';
    var DEFN = '(defn is-yo? [] true) (is-yo?)';
    var DEF2 = '(defn plus-two [n] (+ n 2))' +
               ' (plus-two 2)';

    var DEFN_DEF = '' +
    ' (def max 6)' +
    ' (def min 4)'  +
    ' (defn double-diff [max min] (* 2 (- max min))) ' +
    ' (double-diff 10 1)';

    var DEFN_DEF2 = '' +
    ' (def max 6)' +
    ' (def min 4)'  +
    ' (defn double-diff [max min] (* 2 (- max min))) ' +
    ' (double-diff max min)';

    it('TRU', function() { p.parse(TRU).eval({}).should.be.exactly(true); });
    it('FSE', function() { p.parse(FSE).eval({}).should.be.exactly(false); });

    it('ADD', function() { p.parse(ADD).eval({}).should.be.exactly(120); });
    it('SUB', function() { p.parse(SUB).eval({}).should.be.exactly(75); });
    it('MLT', function() { p.parse(MLT).eval({}).should.be.exactly(400); });
    it('DIV', function() { p.parse(DIV).eval({}).should.be.exactly(50); });

    it('EQL', function() { p.parse(EQL).eval({}).should.be.exactly(true); });
    it('GTE', function() { p.parse(GTE).eval({}).should.be.exactly(true); });
    it('LTE', function() { p.parse(LTE).eval({}).should.be.exactly(true); });
    it('GT',  function() { p.parse(GT).eval({}).should.be.exactly(true); });
    it('LT',  function() { p.parse(LT).eval({}).should.be.exactly(true); });

    it('IF',  function() { p.parse(IF).eval({}).should.be.exactly(true); });
    it('IFELS',  function() { p.parse(IFELS).eval({}).should.be.exactly(true); });

    it('CASE',  function() { p.parse(CASE).eval({}).should.be.exactly(true); });
    it('CASE_UNEVEN',  function() { p.parse(CASE).eval({}).should.be.exactly(true); });
    it('CASE_MUCH',  function() { p.parse(CASE).eval({}).should.be.exactly(true); });

    it('DEF',  function() { p.parse(DEF).eval({}).should.be.exactly(200); });
    it('DEFN', function() { p.parse(DEFN).eval({}).should.be.exactly(true); });
    it('DEFN ADD 2', function() { p.parse(DEF2).eval({}).should.be.exactly(4); });
    it('DEFN_DEF',   function() { p.parse(DEFN_DEF).eval({}).should.be.exactly(18); });

    //COMPILE TO JS
    it('JS -> TRU', function() { eval(p.parse(TRU).compile({})).should.be.exactly(true); });
    it('JS -> FSE', function() { eval(p.parse(FSE).compile({})).should.be.exactly(false); });

    it('JS -> ADD', function() { var code = p.parse(ADD).compile({}); eval(code).should.be.exactly(120); });
    it('JS -> SUB', function() { eval(p.parse(SUB).compile({})).should.be.exactly(75); });
    it('JS -> MLT', function() { eval(p.parse(MLT).compile({})).should.be.exactly(400); });
    it('JS -> DIV', function() { eval(p.parse(DIV).compile({})).should.be.exactly(50); });

    it('JS -> EQL', function() { eval(p.parse(EQL).compile({})).should.be.exactly(true); });
    it('JS -> GTE', function() { eval(p.parse(GTE).compile({})).should.be.exactly(true); });
    it('JS -> LTE', function() { eval(p.parse(LTE).compile({})).should.be.exactly(true); });
    it('JS -> GT',  function() { eval(p.parse(GT).compile({})).should.be.exactly(true); });
    it('JS -> LT',  function() { eval(p.parse(LT).compile({})).should.be.exactly(true); });

    it('JS -> IF',    function() { eval(p.parse(IF).compile({})).should.be.exactly(true); });
    it('JS -> IFELS', function() { eval(p.parse(IFELS).compile({})).should.be.exactly(true); });

    it('JS -> CASE',         function() { var code = p.parse(CASE).compile({}); eval(code).should.be.exactly(true); });
    it('JS -> CASE_UNEVEN',  function() { eval(p.parse(CASE).compile({})).should.be.exactly(true); });
    it('JS -> CASE_MUCH',    function() { eval(p.parse(CASE).compile({})).should.be.exactly(true); });

    it('JS -> DEF',  function() { eval(p.parse(DEF).compile({})).should.be.exactly(200); });
    it('JS -> DEFN', function() { var code = p.parse(DEFN).compile({}); eval(code).should.be.exactly(true); });
    it('JS -> DEFN ADD 2', function() { var code = p.parse(DEF2).compile({}); eval(code).should.be.exactly(4); });
    it('JS -> DEFN_DEF',   function() { eval(p.parse(DEFN_DEF).compile({})).should.be.exactly(18); });
    it('JS -> DEFN_DEF2',   function() { eval(p.parse(DEFN_DEF2).compile({})).should.be.exactly(4); });

    it('evals to js', function() {
        p.parse('(def message "Greetings!") (defn greet [] message) (greet)').eval({}).should.be.exactly('Greetings!');
    });

    it('converts to js', function() {
        var code = p.parse('(def message "Greetings!") (defn greet [] message) (greet)').compile({}); eval(code).should.be.exactly('Greetings!');
    });

    function xit(name, fn) { console.log('\x1b[33m  ~ %s\x1b[0m', name); }
    function it(name, fn) {
      try {
        fn();
      } catch (err) {
        console.log('\x1b[31m  ✗ %s\x1b[0m', name);
        console.log('    %s\x1b[0m', err.stack);
        return;
      }
      console.log('\x1b[32m  √ %s\x1b[0m', name);
    }

}
