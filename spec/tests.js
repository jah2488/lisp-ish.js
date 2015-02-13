var should = require('should');
var p = require('../src/grammar');
        require('../src/boolean');
        require('../src/cell');
        require('../src/datum');
        require('../src/list');
        require('../src/misc');
        require('../src/number');
        require('../src/program');
        require('../src/string');
        require('../src/symbol');
        require('../src/vector');

var TRU = 'true';
var FSE = 'false';

var ADD = '(+ 100 (+ 5 (+ 10 5)))';
var SUB = '(- 100 (- 50 25))';
var MLT = '(* 100 (* 2 (* 2 1)))';
var DIV = '(/ 100 (/ 50 25))';

var EQL = '(= 100 (+ 50 50))';
var GTE = '(>= 200 (+ 50 50))';
var LTE = '(<= 100 (+ 50 50))';
var GT = '(> 120 (+ 50 50))';
var LT = '(< 80 (+ 50 50))';

var IF    = '(if (> 10 0) true)';
var IFELS = '(if (< 10 0) false true)';

var CASE = '(case "pick-me" "no" false "pick-me" true 10 false)';
var CASE_UNEVEN = '(case "pick-me" "no" false "pick-me" true 10)';
var CASE_MUCH = '(case "pick-me" "no" false "pick-me" true 10 false "no" false "pick-me" true 10 false)';

var DEF  = '(def yo 100) (+ 100 yo)';
var DEFN = '(defn is-yo? [] true) (is-yo?)';
var DEF2 = '(defn plus-two [n] (+ n 2))' +
           ' (plus-two 2)';

var DEFN_DEF = '' +
' (def max 6)' +
' (def min 4)'  +
' (defn double-diff [max min] (* 2 (- max min))) ' +
' (double-diff 10 1)';

var DEFN_DEF2 = '' +
' (def max 6)' +
' (def min 4)'  +
' (defn double-diff [max min] (* 2 (- max min))) ' +
' (double-diff max min)';

it('TRU', function() { p.parse(TRU).eval({}).should.be.exactly(true); });
it('FSE', function() { p.parse(FSE).eval({}).should.be.exactly(false); });

it('ADD', function() { p.parse(ADD).eval({}).should.be.exactly(120); });
it('SUB', function() { p.parse(SUB).eval({}).should.be.exactly(75); });
it('MLT', function() { p.parse(MLT).eval({}).should.be.exactly(400); });
it('DIV', function() { p.parse(DIV).eval({}).should.be.exactly(50); });

it('EQL', function() { p.parse(EQL).eval({}).should.be.exactly(true); });
it('GTE', function() { p.parse(GTE).eval({}).should.be.exactly(true); });
it('LTE', function() { p.parse(LTE).eval({}).should.be.exactly(true); });
it('GT',  function() { p.parse(GT).eval({}).should.be.exactly(true); });
it('LT',  function() { p.parse(LT).eval({}).should.be.exactly(true); });

it('IF',  function() { p.parse(IF).eval({}).should.be.exactly(true); });
it('IFELS',  function() { p.parse(IFELS).eval({}).should.be.exactly(true); });

it('CASE',  function() { p.parse(CASE).eval({}).should.be.exactly(true); });
it('CASE_UNEVEN',  function() { p.parse(CASE).eval({}).should.be.exactly(true); });
it('CASE_MUCH',  function() { p.parse(CASE).eval({}).should.be.exactly(true); });

it('DEF',  function() { p.parse(DEF).eval({}).should.be.exactly(200); });
it('DEFN', function() { p.parse(DEFN).eval({}).should.be.exactly(true); });
it('DEFN ADD 2', function() { p.parse(DEF2).eval({}).should.be.exactly(4); });
it('DEFN_DEF',   function() { p.parse(DEFN_DEF).eval({}).should.be.exactly(18); });

//COMPILE TO JS
it('JS -> TRU', function() { eval(p.parse(TRU).compile({})).should.be.exactly(true); });
it('JS -> FSE', function() { eval(p.parse(FSE).compile({})).should.be.exactly(false); });

it('JS -> ADD', function() { var code = p.parse(ADD).compile({}); eval(code).should.be.exactly(120); });
it('JS -> SUB', function() { eval(p.parse(SUB).compile({})).should.be.exactly(75); });
it('JS -> MLT', function() { eval(p.parse(MLT).compile({})).should.be.exactly(400); });
it('JS -> DIV', function() { eval(p.parse(DIV).compile({})).should.be.exactly(50); });

it('JS -> EQL', function() { eval(p.parse(EQL).compile({})).should.be.exactly(true); });
it('JS -> GTE', function() { eval(p.parse(GTE).compile({})).should.be.exactly(true); });
it('JS -> LTE', function() { eval(p.parse(LTE).compile({})).should.be.exactly(true); });
it('JS -> GT',  function() { eval(p.parse(GT).compile({})).should.be.exactly(true); });
it('JS -> LT',  function() { eval(p.parse(LT).compile({})).should.be.exactly(true); });

it('JS -> IF',    function() { eval(p.parse(IF).compile({})).should.be.exactly(true); });
it('JS -> IFELS', function() { eval(p.parse(IFELS).compile({})).should.be.exactly(true); });

it('JS -> CASE',         function() { var code = p.parse(CASE).compile({}); eval(code).should.be.exactly(true); });
it('JS -> CASE_UNEVEN',  function() { eval(p.parse(CASE).compile({})).should.be.exactly(true); });
it('JS -> CASE_MUCH',    function() { eval(p.parse(CASE).compile({})).should.be.exactly(true); });

it('JS -> DEF',  function() { eval(p.parse(DEF).compile({})).should.be.exactly(200); });
it('JS -> DEFN', function() { var code = p.parse(DEFN).compile({}); eval(code).should.be.exactly(true); });
it('JS -> DEFN ADD 2', function() { var code = p.parse(DEF2).compile({}); eval(code).should.be.exactly(4); });
it('JS -> DEFN_DEF',   function() { eval(p.parse(DEFN_DEF).compile({})).should.be.exactly(18); });
it('JS -> DEFN_DEF2',   function() { eval(p.parse(DEFN_DEF2).compile({})).should.be.exactly(4); });

it('evals to js', function() {
    p.parse('(def message "Greetings!") (defn greet [] message) (greet)').eval({}).should.be.exactly('Greetings!');
});

it('converts to js', function() {
    var code = p.parse('(def message "Greetings!") (defn greet [] message) (greet)').compile({}); eval(code).should.be.exactly('Greetings!');
});

function xit(name, fn) { console.log('\x1b[33m  ~ %s\x1b[0m', name); }
function it(name, fn) {
  try {
    fn();
  } catch (err) {
    console.log('\x1b[31m  ✗ %s\x1b[0m', name);
    console.log('    %s\x1b[0m', err.stack);
    return;
  }
  console.log('\x1b[32m  √ %s\x1b[0m', name);
}
