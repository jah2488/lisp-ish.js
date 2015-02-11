# Wisp
*because its barely there*
Its kind of a lisp and kind of javascript.


### How to do

__To Run/Eval code__
```sh
./lispish.js -e '(defn plus-two [n] 
                   (+ 2 n)) 
                 (plus-two 4)'
6
```

__To Compile to Javascriptcode__
```sh
./lispish.js -c '(defn plus-two [n] 
                   (+ 2 n)) 
                 (plus-two 4)'
function plus_two(n) { return (function(args) { return parseFloat(2) + parseFloat(n); })(); } plus_two(4);
```

__To Run Tests__
```sh
./lispish.js -t 
```
