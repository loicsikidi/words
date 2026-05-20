+++
date = '2026-05-10T00:22:49+02:00'
draft = false
title = "Why I Prefer Structs Over Variadic Functions in Go"
tags = ['programming', 'go']
+++

After several years of practicing Go, I must admit that I'm not a big fan of variadic functions[^1]. I'll try to explain why and why I greatly prefer using *structs*.

## Definition

Let's start with a quick reminder of what variadic functions are for those unfamiliar with the concept.

This pattern is generally used to configure options in a flexible/dynamic way when creating an instance of a structure.

Let's look at a concrete example:

```go
type options struct {
	name  string
	debug bool
}

// Option represents a function that can modify the options of a Struct.
type Option func(o *options)

// WithDebug is an option that enables debug mode for a Struct.
func WithDebug() Option {
	return func(o *options) {
		o.debug = true
	}
}

// WithName is an option that sets the name for a Struct.
func WithName(name string) Option {
	return func(o *options) {
		o.name = name
	}
}

type Struct struct {
	options *options
}

func New(opts ...Option) *Struct {
	o := new(options)
	for _, option := range opts {
		option(o)
	}
	return &Struct{options: o}
}

func main() {
    s1 := New(WithName("foo"), WithDebug())
    fmt.Printf("config 1: %+v\n", *s1.options)
    s2 := New(WithDebug())
    fmt.Printf("config 2: %+v\n", *s2.options)
}
```

> [!NOTE]
> The complete example is available via the Go playground: <a href="https://go.dev/play/p/SpGQz7cTeDE" target="_blank">here</a>.

As we can see, the idea is to chain optional functions to configure a structure flexibly based on needs.

> [!TIP]
> It's conventional to use the `With` prefix for this type of function, which allows quick understanding that these are configurable options.

On paper, this may seem ideal, but in practice, I've encountered several limitations and drawbacks.

## My Grievances

### 1. Information Scattering

*By design*, the configuration is scattered across multiple functions, which mechanically makes the code more complex than it should be. Indeed, the user must navigate between the configuration *struct* and the different functions to understand how things work.

### 2. Verbosity

When a configuration requires many options, the code quickly becomes verbose.

### 3. Poorly Suited for Configuration as Code

In more and more projects I work on, configuration is managed via configuration files (e.g. YAML, TOML). Variadic functions don't integrate naturally into this type of use case, which makes the code less flexible.

Don't get me wrong, as the example below shows, it's entirely possible to achieve the goal, but I find the process less intuitive and more verbose than it should be.

{{< details summary="Example" >}}

```go
type options struct {
    Name  string `yaml:"name"`
    Debug bool   `yaml:"debug"`
}

type Option func(o *options) error

func WithConfig(raw []byte) Option {
    return func(o *options) error {
        if err := yaml.Unmarshal(raw, o); err != nil {
            return fmt.Errorf("failed to unmarshal config: %w", err)
        }
        return nil
    }
}
```

{{< /details >}}



## The Alternative

Fundamentally, *variadic functions* are just an abstraction for configuring a *struct*. I believe in reducing complexity by using the *struct* directly. This has the advantage of centralizing information in one place, which makes the code more readable and easier to maintain.

Here's what it can look like:

```go
// user just needs to read Config's fields
// to understand the configuration
type Config struct {
    Name  string `yaml:"name"`
    Debug bool   `yaml:"debug"`
}

// setDefaults sets the default values for Config fields
func (c *Config) setDefaults() {
    if c.Name == "" {
        c.Name = "defaultName"
    }
}

type Struct struct {
    cfg *Config
}

func New(config *Config) *Struct {
    config.setDefaults()
    return &Struct{
        cfg: config,
    }
}
```

> [!NOTE]
> The complete example is available via the Go playground: <a href="https://go.dev/play/p/vftAFNILkWN" target="_blank">here</a>.

This approach doesn't necessarily reduce the number of lines of code, but addresses the 3 grievances mentioned previously:

1. centralizes information in a single structure
2. the user only needs to provide a config
    * the `setDefaults` function takes care of filling in optional values
3. it's easy to serialize and deserialize the configuration from YAML files, which facilitates integration with external configuration systems.

## Conclusion

Despite my hostility towards variadic functions as a configuration mechanism, I admit that this pattern can be relevant in certain cases (for example, when the number of options is limited and configuration as code is not necessary). For my part, the divorce is final: I've completely stopped using them in my projects.

That's all for me. Cheers!

[^1]: given its overrepresentation in the Go community, I think my opinion can be considered an *unpopular opinion*.
