(call_expression
  (scoped_identifier
    path: (identifier) @path (#eq? @path "sqlx")
    name: (identifier) @name (#any-of? @name "query" "query_as" "query_scalar"))

  (arguments
    (string_literal
      (string_content) @injection.content))

  (#set! injection.language "sql")
)


(call_expression
  (generic_function
    (scoped_identifier
      path: (identifier) @path (#eq? @path "sqlx")
      name: (identifier) @name (#any-of? @name "query" "query_as" "query_scalar")))

  (arguments
    (string_literal
      (string_content) @injection.content))

  (#set! injection.language "sql")
)
