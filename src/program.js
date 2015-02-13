require('./grammar').Parser.Program = {
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

        value += 'function _if(cond, predT, predF) { if (cond) { return predT } else { return predF } } '
        value += 'function mod(n, x) { return parseFloat(n) % parseFloat(x) } ';
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
