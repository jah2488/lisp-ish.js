require('./grammar').Parser.String = {
    name: 'String',
    eval: function(scope) {
        return eval(this.textValue); // Maybe remove eval call
    },
    compile: function(scope) {
        return this.textValue;
    }
};
