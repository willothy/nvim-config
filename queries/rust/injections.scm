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


(
  (macro_invocation
    macro: (scoped_identifier
             path: (identifier) @sqlx_crate
             name: (identifier) @sqlx_macro
            )
    (token_tree
      (string_literal
        (string_content) @injection.content
      )
    )
  )
  ;; Only match sqlx::query* style macros
  (#eq? @sqlx_crate "sqlx")
  (#match? @sqlx_macro "^query(_as|_scalar|_file|_file_as)?$")
  (#set! injection.language "sql")
)

(
  (macro_invocation
    macro: (scoped_identifier
             path: (identifier) @sqlx_crate
             name: (identifier) @sqlx_macro
            )
    (token_tree
      (raw_string_literal
        (string_content) @injection.content
      )
    )
  )
  ;; Only match sqlx::query* style macros
  (#eq? @sqlx_crate "sqlx")
  (#match? @sqlx_macro "^query(_as|_scalar|_file|_file_as)?$")
  (#set! injection.language "sql")
)
