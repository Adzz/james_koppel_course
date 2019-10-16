#### 1

Compare the write_message methods of the console-based and file-based backends. There is hidden coupling between them. What is the hidden coupling? What changes does this hidden coupling inhibit? How would you refactor them to eliminate it.

https://github.com/django/django/blob/master/django/core/mail/backends/console.py#L16
https://github.com/django/django/blob/master/django/core/mail/backends/filebased.py#L43

Answer:

The hidden coupling seems to be from the file based backend using console backend as a base. Both the file backend and the console backend do this triple:

```python
        self.stream.write(thing + b'\n')
        self.stream.write(b'-' * 79)
        self.stream.write(b'\n')
```

and right now it is possible for one to change without any warning or noise being generated suggesting that the other does too.

#### 2

The send_messages methods of both the SMTP-based and console-based (and file-based, by inheritance) backends have a common notion of failing silently according to an option. #

1. What is the essence of the "fail-silently" pattern? In other words, if I gave code where all identifiers were obfuscated, how would you identify code that implemented the "fail-silently" feature?

I think the essence of any fail silently pattern is not doing anything when something doesn't work the way it should. In this case it looks like the

```python
  self.open()
```

can fail and we don't really do anything different if it does, we just return.

2. What are the design decisions behind the two backend's implementation of fail-silently, and how might a change to these decisions affect both implementations?

3) Sketch how to refactor the code to eliminate this hidden coupling. (Hint: Use Python's with statement)
