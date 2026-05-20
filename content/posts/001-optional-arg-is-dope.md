+++
date = '2026-05-09T11:14:30+02:00'
draft = false
title = 'Making Go APIs More Ergonomic with Optional Arguments'
tags = ['programming', 'go']
+++

## Introduction

In Go, as in all programming languages, it's sometimes useful to have optional arguments in functions.

The Go language supports this functionality but in a very limited way, as shown in the example below:

```go
func Greetings(name string, age ...int) {
    if len(age) > 0 {
        fmt.Printf("Hello %s, you are %d years old\n", name, age[0])
    } else {
        fmt.Printf("Hello %s\n", name)
    }
}

func main() {
    Greetings("Alice")
    Greetings("Bob", 30)
    Greetings("Chad", 40, 100) // only the first value is used
}
```

> [!NOTE]
> The complete example is available via the Go playground: <a href="https://go.dev/play/p/HBzgGmQQBsd" target="_blank">here</a>.

We can notice that we use a variadic argument to handle optional arguments. This approach works but as we can see, it's limited to a single argument which **must** necessarily be the last one.

This may appear as a limitation but I think it's rather a safeguard that forces us to think about the design of our functions.

## Optional Arg can bring elegance

On multiple occasions, I've noticed that using an optional argument can make the code more readable.

I'll illustrate this with a concrete example.

Let's analyze the code below:

```go
type Config struct {
    Port int
    Host string
    Timeout time.Duration
}

var defaultConfig = Config{
    Port:    8080,
    Host:    "localhost",
    Timeout: 30 * time.Second,
}
 
func NewServerImplemA(config *Config) *Server {
    if config == nil {
        config = &defaultConfig
    }
    return &Server{
        Config: *config,
    }
}

func NewServerImplemB(config Config) *Server {
    return &Server{
        Config: config,
    }
}

func main() {
    defaultSrvA := NewServerImplemA(nil)
    defaultSrvB := NewServerImplemB(defaultConfig)
}
```

> [!NOTE]
> The complete example is available via the Go playground: <a href="https://go.dev/play/p/9j2vNUoXa2_G" target="_blank">here</a>.

Often as an API user, we want to rely on default values because they are generally sufficient for the majority of use cases.

Here, we end up with two interface contracts that I find perfectible.

| Implementation | Comment |
|:--------------:|:--------:|
| `A` | We end up providing `nil` (especially if the default config is a private variable) which is anything but intuitive. |
| `B` | We have to read the code to find the constant, which can be tedious. |

<p align="center"><b>Table: </b><em>Implementation Comparison</em></p>


In such a scenario, I think using an optional argument is the most elegant from an ergonomic point of view.

Indeed, the user faces two clear choices:

1. Use the default configuration by passing no argument
    * it's up to the API to provide a default configuration
2. Provide a custom configuration by passing an argument
    * this action marks a clear intention from the end user[^1]

This vision is exemplified in the code below:

```go
func NewServer(optionalCfg ...Config) *Server {
    // do stuff here
    return &Server{
        Config: cfg,
    }
}

func main() {
    defaultServer := NewServer()
    customServer := NewServer(customCfg)
}
``` 

> [!IMPORTANT]
> When I use this pattern, it seems **essential** to me to explicitly indicate that the argument is optional by using the `optional` prefix to avoid any confusion.

## Making things more generic

To make this approach more generic, I coded a mini helper that fits in about twenty lines to make my life easier.

```go
var errArgNotProvided = errors.New("argument not provided")

func optionalArg[T any](arg []T) (T, error) {
	if len(arg) == 0 {
		var zero T
		return zero, errArgNotProvided
	}
	return arg[0], nil
}

func OptionalArg[T any](arg []T) T {
	v, _ := optionalArg(arg)
	return v
}

func OptionalArgWithDefault[T any](arg []T, defaultValue T) T {
	v, err := optionalArg(arg)
	if err != nil {
		return defaultValue
	}
	return v
}
```

Now, we can start using this pattern with less boilerplate.

```go
func Greetings(name string, optionalAge ...int) {
    age := OptionalArg(optionalAge)
    if age > 0 {
        fmt.Printf("Hello %s, you are %d years old\n", name, age)
    } else {
        fmt.Printf("Hello %s\n", name)
    }
}

func GreetingsWithDefault(name string, optionalAge ...int) {
    age := OptionalArgWithDefault(optionalAge, 30)
    fmt.Printf("Hello %s, you are %d years old\n", name, age)
}
```

> [!NOTE]
> The complete example is available via the Go playground: <a href="https://go.dev/play/p/JSHV8mMXkAR" target="_blank">here</a>.

## Conclusion

In summary, I think the optional argument is an elegant mechanism to simplify code and make it more readable.

To my great surprise, this is a pattern that is quite rarely found in Go libraries, even though it could greatly improve the ergonomics of APIs.

Nevertheless, it's important to use discernment and use it when appropriate.

Here are the rules I recommend following:

1. Use optional arguments only when it truly improves the API ergonomics for the end user.
2. Prefix optional arguments with `optional` to clearly indicate their nature.
3. Clearly document the default value via a constant and/or a comment.

That's all for this post. Cheers!

[^1]: we assume here that the user knows what they're doing and understands the implications of their choices.
