
.PHONY: test
test:
	nvim --headless -c "PlenaryBustedFile ./lua/spec/ringbuf_spec.lua"
