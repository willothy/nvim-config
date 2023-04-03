local state = {
	git = {
		status_dict = {
			head = "",
			added = 0,
			removed = 0,
			changed = 0,
		},
		has_changes = false,
	},
	lsp = {
		clients = {},
		attached = false,
	},
}

return state
