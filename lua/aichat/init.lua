local M = {}

-- default options
M.options = {
	api_url = "https://api.openai.com/v1/chat/completions",
	api_auth = nil,
	ai_model = "gpt-3.5-turbo",
	user_tag = "## [user]",
	assistant_tag = "## [ai]",
	system_tag = "# [sys]",
	request_timeout_s = 30,
	-- auto_insert_on_open = true,
	keymaps = {
		toggle_chat = "<leader>ta",
		get_response = "<C-m>",
		-- insert_selected_text = "<leader>ti",
	},
}

M.state = {
	chat_window_open = false,
}

function M.setup(opts)
	M.options = vim.tbl_extend("force", M.options, opts or {})
	vim.keymap.set({ "n", "v" }, M.options.keymaps.toggle_chat, M.toggle_chat, { noremap = true, silent = true })
end

local request = require("aichat.request")
local chat = require("aichat.chat")

function M.open_chat()
	vim.cmd("vsplit")
	local win = vim.api.nvim_get_current_win()
	local starting_lines = {}
	-- TODO: add the selected text (if any) as context

	local buf = M.state.chat_buffer_id

	if not buf or not vim.fn.bufexists(buf) then
		buf = vim.api.nvim_create_buf(true, true)
		-- TODO: implement a default system prompt
		chat.set_buf_options(buf)
		table.insert(starting_lines, M.options.user_tag)
	end

	M.state.chat_buffer_id = buf
	M.state.chat_window_id = win

	chat.set_win_options(win)

	vim.api.nvim_win_set_buf(win, buf)
	chat.attach_buf_keymaps(buf, M.options.keymaps)

	if vim.api.nvim_buf_line_count(buf) > 1 then
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, starting_lines)
	else
		vim.api.nvim_buf_set_lines(buf, 0, 0, false, starting_lines)
	end
	vim.cmd("normal! G")
end

function M.close_chat()
	chat.dettach_buf_keymaps(M.state.chat_buffer_id, M.options.keymaps)
	vim.api.nvim_win_close(M.state.chat_window_id, true)
end

function M.toggle_chat()
	if vim.api.nvim_win_is_valid(M.state.chat_window_id or -1) then
		M.close_chat()
	else
		M.open_chat()
	end
end

function M.get_ai_response()
	if not M.state.chat_buffer_id then
		vim.lua_error("Cannot get response without context from a buffer")
	end

	vim.api.nvim_buf_set_option(M.state.chat_buffer_id, "modifiable", false)
	request.trigger_completion(M.options, M.state.chat_buffer_id)

	if vim.api.nvim_get_current_buf() == M.state.chat_buffer_id then
		vim.cmd("normal! G")
	end
end

return M
