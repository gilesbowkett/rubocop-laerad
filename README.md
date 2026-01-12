# rubocop-laerad

A RuboCop extension that detects single-use variables in Ruby code.

## What It Detects

Single-use variables are variables that are defined but used only once (or not at all).

```ruby
# Flagged: x is defined and used only once
def example
  x = compute_value
  x
end

# Not flagged: x is used multiple times
def example
  x = compute_value
  x + x
end
```

## Installation

Add to your Gemfile:

```ruby
gem "rubocop-laerad", require: false
```

Or install directly:

```
gem install rubocop-laerad
```

## Usage

Add to your `.rubocop.yml`:

```yaml
require:
  - rubocop-laerad

Laerad/SingleUseVariable:
  Enabled: true
```

Then run RuboCop as usual:

```
bundle exec rubocop
```

Or run only the single-use variable check:

```
bundle exec rubocop --only Laerad/SingleUseVariable
```

## Detection Rules

A variable is flagged when its total count (definition + references) is 2 or less:

- Count 1: Variable defined but never used
- Count 2: Variable defined and used exactly once

### Exemptions

The rule does not flag:

- **Underscore-prefixed variables**: `_unused` or `_` are conventionally ignored
- **Block parameters used via `yield`**: The block is implicitly used
- **Parameters when bare `super` is called**: All parameters are implicitly passed

### Scope Handling

The cop tracks variables across lexical scopes:

- Method definitions create new scopes
- Blocks create new scopes but can reference outer variables (closures)

## Examples

```ruby
# Flagged: unused variable
def example
  x = 1  # x is never used
end

# Flagged: single-use variable
def example
  x = 1
  puts x  # x used only once
end

# Not flagged: multi-use variable
def example
  x = 1
  puts x
  puts x  # x used twice
end

# Not flagged: underscore prefix
def example(_unused)
  # _unused is conventionally ignored
end

# Not flagged: yield uses block implicitly
def example(&block)
  yield  # block is used via yield
end

# Not flagged: bare super uses all params
def example(a, b, c)
  super  # a, b, c implicitly passed
end
```

## Development

Run tests:

```
bundle install
bundle exec rake test
```

## License

MIT
