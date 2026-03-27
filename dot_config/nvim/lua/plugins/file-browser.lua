return {
  "nvim-telescope/telescope-file-browser.nvim",
  keys = {
    {
      "<leader>sB",
      ":Telescope file_browser path=%:p:h:=%<cr>",
      desc = "File browser",
    },
  },
  config = function()
    require("telescope").load_extension("file_browser")
  end,
}
