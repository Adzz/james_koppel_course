## [Hoare Triples](https://cdn.filestackcontent.com/preview=css:%22https%3A%2F%2Fassets.teachablecdn.com%2Fcss%2Ffilestack-pdf-viewer.css%22/eoJx6BSSyOg1cAvyftXl#page=1&zoom=auto,-13,792)

They take the form:

1. Precondition
2. Command
3. Postcondition

```
{Pre}Command{Post}
{P}S{Q}
```

They should be read as "if P is true, then, after S executes, Q will be true"

If the strongest postcondition of A is stronger than the weakest precondition of B, the program has modularity,
