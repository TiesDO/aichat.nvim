local M = {}

local util = require("aichat.util")

function M.parse_buffer(buf, options)
	local line_count = vim.api.nvim_buf_line_count(buf)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, line_count, false)

	local messages = {}

	for _, line in ipairs(lines) do
		if util.starts_with(line, options.user_tag) then
			table.insert(messages, {
				role = "user",
				content = "",
			})
		elseif util.starts_with(line, options.assistant_tag) then
			table.insert(messages, {
				role = "system",
				content = "",
			})
		elseif util.starts_with(line, options.system_tag) then
			table.insert(messages, {
				role = "system",
				content = "",
			})
		elseif #messages > 0 then
			-- if line is not a role append as content to most recent message
			local message = messages[#messages]
			message.content = message.content .. line
		end
	end

	return messages
end

function M.set_buf_options(buf)
	vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
end

function M.set_win_options(win)
	vim.api.nvim_win_set_option(win, "linebreak", true)
	vim.api.nvim_win_set_option(win, "wrap", true)
end

function M.attach_buf_keymaps(buf, keymaps)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		keymaps.get_response,
		"<cmd>lua require('aichat').get_ai_response()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"i",
		keymaps.get_response,
		"<cmd>lua require('aichat').get_ai_response()<CR>",
		{ noremap = true, silent = true }
	)
end

function M.dettach_buf_keymaps(buf, keymaps)
	vim.api.nvim_buf_set_keymap(buf, "n", keymaps.get_response, "", { noremap = true, silent = false })
	vim.api.nvim_buf_set_keymap(buf, "i", keymaps.get_response, "", { noremap = true, silent = false })
end

-- TODO: implement i guess?
function M.chat_exists() end
function M.is_chat_open() end

function M.insert_response(response, buf, a_tag, u_tag)
	local new_lines = {}
	table.insert(new_lines, a_tag)
	for l in string.gmatch(response, "[^\r\n]+") do
		table.insert(new_lines, l)
	end
	table.insert(new_lines, u_tag)
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, new_lines)
end

return M
