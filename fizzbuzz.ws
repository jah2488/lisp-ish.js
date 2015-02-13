(defn fizzbuzz [n]
  (if (= 0 (mod n 15))
    "fizzbuzz"
    (if (= 0 (mod n 5))
      "buzz"
      (if (= 0 (mod n 3))
        "fizz"
        n))))


