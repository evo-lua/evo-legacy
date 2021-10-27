assert(type(table.count) == "function", "Should expose the count() extension")

assert(table.count({}) == 0, "Should return 0 for empty tables")
assert(table.count({ 42, 43, 44 }) == 3, "Should count all elements in the array part")
assert(table.count({ hi = 42, test = 43, meep = 44}) == 3, "Should count all elements in the hash part")
assert(table.count({hi = 42, 1, 2, 3, test = 43, meep = 44}) == 6, "Should count the elements of both array and hash parts combined")
assert(table.count({1, nil, 2, nil, 3}) == 3, "Should skip nils in the array part")
assert(table.count({hi = 42, nil, test = 43, nil, meep = 44}) == 3, "Should skip nils in the hash part")
assert(table.count({hi = 42, nil, 43, nil, meep = 44}) == 3, "Should not count nil in tables that have both an array and a hash part")

print("OK\tExtensions\ttable")