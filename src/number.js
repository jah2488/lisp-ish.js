var toFloat = function(scope) {
    return parseFloat(this.textValue);
};

require('./grammar').Parser.Number = {
    name: 'Number',
    eval: toFloat,
    compile: toFloat
};
