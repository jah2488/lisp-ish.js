require('./grammar').Parser.Cell = {
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
            return '_if (' + condition.compile(scope, env) + ', ' + ifTrue.compile(scope, env) + ', ' + (ifFalse !== undefined ? ifFalse.compile(scope, env) : null) + ')';
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
