local opts = {
  mappings = {
    nv = {
      motions = {
        new_trail_mark = "<leader>mt",
        track_back = "<leader>mb",
        peek_move_next_down = "<leader>mk",
        peek_move_previous_up = "<leader>mj",
        move_to_nearest = "<leader>mn",
        toggle_trail_mark_list = "<C-m>",
      },
      actions = {
        delete_all_trail_marks = false,
      },
    },
  },
}

require("trailblazer").setup(opts)
