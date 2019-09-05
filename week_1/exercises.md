## Hoare Triples

### Exercise 1

> Conceptual question: In the latter example, how could we change the code without altering the postcondition? How does the “forgetting” of assertions correspond to a form of modularity?

The code given looks like this:

```
{ true }
x = 10;
{ x > 1}
y = 42;
{x > 1, y > 1}
z = x + y ;
{ z > 1}
```

We can change the code in anyway that would still ensure that `z > 1`, some examples are

- Set x to any other value that is greater than 0, keeping y the same
- Set y to any other value that is greater than 0, keeping x the same
- Set y to any positive number, and set x to any value that is less than y's size
- Set x to any positive number, and set y to any value that is less than x's size

Forgetting the assertions leaves lots of room to change things without breaking any assumption in the logic provided by the assertions. The magic is in deciding what can be "forgotten".

### Exercise 2

Fill this out:

```
{  }
b := 2 − a
{  }
c := b ∗ 2
{  }
d := c + 1
{d  =  5}
```

```
{ a = -2 }
b := 2 − a
{ b = 2 }
c := b ∗ 2
{ c = 4 }
d := c + 1
{d = 5}
```

### Exercise 3

In this exercise, assume all variables are integers, all division is integer division (rounds toward 0), and that x/0 == 0 for all x. Note on notation: `/\` is ASCII for `∧`, which denotes the logical "and" `=>` is ASCII for `⇒` and is read "implies". `A⇒B` means "if A is true, then B is true".

1.  Look at the code in Figure 2. Fill in the assertions between each line. We have done the last and first ones for you.

Fig 2

```
{ true }
d := (2−( a +1)/ a ) / 2;
{  }
m := d∗2 + (1−d )∗3;
{}
x := b∗2;
{}
x := x∗2;
{}
x := m ∗ x;
{ }
x := x + 1;
{(( a <=  0 ) => x =  8 ∗ b + 1) /\ (( a>0 ) => x = 12 ∗ b + 1)}
```

bottom line to me reads like this:

```
If a is <= 0 then x is 8*b+1 && if a > 0 then x = 12*b+1
```

If I were to write that in code (elixir) it would be:

```elixir
x = case a do
  a when a <= 0 -> 8*b+1
  a when a > 0 -> 12*b+1
end

# Or

def x(0), do: 8*b+1
def x(a) when a > 0, do: 12*b+1
```

So let's try:

```
{ true }
d := (2−(a+1)/a)/2;
{ (( a <=  0 ) => 3x-dx = 4b/2 /\ (( a > 0 ) => 3x-dx = 6b/2  }
m := d∗2 + (1 − d) ∗ 3;
{ (( a <=  0 ) => m*x = 4b/2 /\ (( a > 0 ) => m*x = 6b/2 }
x := b ∗ 2;
{ (( a <=  0 ) => m*x = 8b/2 /\ (( a > 0 ) => m*x = 12b/2 }
x := x ∗ 2;
{ (( a <=  0 ) => m*x = 8b) /\ (( a > 0 ) => m*x = 12b) }
x := m ∗ x;
{ (( a <=  0 ) => x = 8*b) /\ (( a > 0 ) => x = 12b)}
x := x + 1;
{(( a <=  0 ) => x = 8∗b+1) /\ (( a > 0 ) => x = 12∗b+1)}
```

2.  In what sense does this code contain a conditional?

In the sense that there are two kinds of statements that hold true about the code by the end of it? Strangely this makes me think any code which could have more than one fact about it stated could have
conditionals in it? Like imagine this:
{ X > 0 }
x := x + 10
{ x > 5}

Well, you could also say:

{ x >= 0 }
x := x + 10
{ x > 9 /\ (x=0) => x = 10}

### Exercise 4

{ true }
d := (2−(a+1)/a)/2;
{ (( a <= 0 ) => 3x-dx = 4b/2 /\ (( a > 0 ) => 3x-dx = 6b/2 }
m := d∗2 + (1 − d) ∗ 3;
{ (( a <= 0 ) => m*x = 4b/2 /\ (( a > 0 ) => m*x = 6b/2 }
x := b ∗ 2;
{ (( a <= 0 ) => m*x = 8b/2 /\ (( a > 0 ) => m*x = 12b/2 }
x := x ∗ 2;
{ (( a <= 0 ) => m*x = 8b) /\ (( a > 0 ) => m*x = 12b) }
x := m ∗ x;
{ (( a <= 0 ) => x = 8\*b) /\ (( a > 0 ) => x = 12b)}
x := x + 1;
{(( a <= 0 ) => x = 8b+1) /\ (( a > 0 ) => x = 12b+1)}

My instinct is to do this but don't know how that helps? I think that not being fully confident in Exercise 3 makes this difficult.

```
{ true }
d := (2−(a+1)/a)/2;
m := d∗2 + (1 − d) ∗ 3;
x := m ∗ x;
x := b ∗ 2;
x := x ∗ 2;
x := x + 1;
```

### Exercise 5

Prove this sequential search procedure correct by choosing a proper loop invariant:

```
{ true }
i := 0
{  }
while arr[i] != val && i < n do
{ arr[i] != val, && 1 < n }
i := i+1
{ i > 0, }
end
{ arr[i] == val || (forall j, (j>= 0 && j<n) => arr[j] != val) }
```






