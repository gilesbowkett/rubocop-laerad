def with_keyword(foo: "default")
  puts foo
  puts foo
end

def with_keyword_unused(bar: "default")
  puts "nothing"
end

def with_single_use_local
  baz = "value"
  puts baz
end
