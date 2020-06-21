# Used by "mix format"
locals_without_parens = [
  deftagged: 1,
  deftagged: 2,
  deftaggedp: 1,
  deftaggedp: 2
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]
