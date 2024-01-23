((function_call
  name: (_) @_vimcmd_identifier
  arguments:
    (arguments
      (string
        content: _ @injection.content)))
  (#set! injection.language "graphql")
  (#any-of? @_vimcmd_identifier "gql"))

