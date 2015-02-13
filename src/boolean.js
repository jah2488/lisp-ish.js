var compute = function(scope) {
    return this.textValue === 'true';
};

require('./grammar').Parser.Boolean = {
    name: 'Boolean',
    eval: compute,
    compile: compute
};
