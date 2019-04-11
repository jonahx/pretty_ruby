[![996.icu](https://img.shields.io/badge/link-996.icu-red.svg)](https://996.icu)

# What does it do?

Adds helpful methods and new syntax to existing methods to improve readability and expressiveness.

Examples will explain best:

```ruby
require 'pretty_ruby'
using PrettyRuby

# map methods that require arguments
arr = [ ['a', 'b', 'c'], ['d', 'e', 'f'] ]
arr.map(:join, '-') #=> [ 'a-b-c', 'd-e-f' ]

# use >> as a pipeline operator
arr = 'hello'.chars
arr.map(:next >> :upcase).join('-') #=> "I-F-M-M-P"

# support negative take and drop
arr = [1, 2, 3, 4, 5]
arr.take(-2) # => [4, 5]
arr.drop(-2) # => [1, 2, 3]

# add tail / init
arr.tail # => [2, 3, 4, 5]
arr.init # => [1, 2, 3, 4]

# scan without arguments
'abcde'.scan #=> ["a", "ab", "abc", "abcd", "abcde"]

# scan with arguments
arr = [1, 2, 3, 4, 5]
arr.scan(:+) #=> [1, 3, 6, 10, 15]
arr.scan(:*) #=> [1, 2, 6, 24, 120]
```

# TODO

Document other features

Go through the remaining Enumerable and Array methods to support the new syntax where relevant.

- `count`
- `detect`
- `find_index`
- `find_all`
- `select`
- `reject`
- `collect`
- `map`
- `flat_map`
- `collect_concat`
- `inject`
- `reduce`
- `partition`
- `group_by`
- `first`
- `all`?
- `any`?
- `one`?
- `none`?
- `minmax`
- `minmax_by`
- `member`?
- `each_with_index`
- `reverse_each`
- `each_entry`
- `each_slice`
- `each_cons`
- `each_with_object`
- `zip`
- `take`
- `take_while`
- `drop`
- `drop_while`
- `cycle`
- `chunk`
- `slice_before`
- `slice_after`
- `slice_when`
- `chunk_while`
- `sum`
- `uniq`
