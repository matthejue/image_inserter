local configs = require("latex_image_inserter.configs")
local state = require("latex_image_inserter.state")

local M = {}

function set_keymaps()
	vim.keymap.set("n", state.opts.keys.next, function()
		local input
		vim.ui.input({ prompt = "Image name: " }, function(inp)
			input = inp
			path = vim.fn.expand("%:p:h")
			if vim.fn.isdirectory(path .. "/figures") == 0 then
				vim.fn.system("mkdir " .. path .. "/figures")
			end
			vim.fn.system("xclip -selection clipboard -t image/png -o >" .. path .. "/figures/" .. input)
			local line
			local col
			line, col = unpack(vim.api.nvim_win_get_cursor(0))
			vim.api.nvim_buf_set_text(
				0,
				line - 1,
				col,
				line - 1,
				col,
				{ [[\includegraphics[width=\linewidth]{]] .. "./figures/" .. input .. "}" }
			)
		end)
	end, { remap = false })
end

function M.setup(opts)
	state.opts = vim.tbl_deep_extend("keep", opts, configs)

	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*.tex",
		callback = set_keymaps,
	})
end

return M
