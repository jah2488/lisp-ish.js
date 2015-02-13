var compute = function (scope, env) {
    var cells  = this.data.elements;
    var proc   = cells[0].eval(scope, env);
    return proc.call(scope, cells.slice(1));
};

require('./grammar').Parser.Vector = {
    name: 'Vector',
    eval: compute,
    compile: compute
};


