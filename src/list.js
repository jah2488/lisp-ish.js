require('./grammar').Parser.List = {
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
            return fn_name + '(' + cells.slice(1).map(function(c) { return c.compile(scope, env)}).join(', ') + ') ';
        }
    }
};

