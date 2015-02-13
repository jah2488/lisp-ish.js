var resolve = function (scope) {
    return scope.resolve(this.textValue);
};

require('./grammar').Parser.Symbol = {
    name: 'Symbol',
    eval: resolve,
    compile: resolve
};
