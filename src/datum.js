require('./grammar').Parser.Datum = {
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
        //I feel like this is where built-in fn look up should go, to only generate the fns needed instead of the entire stdlib.
        return this.textValue;
    }
};
