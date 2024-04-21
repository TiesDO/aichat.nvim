M = {}

function M.get_selection()
	local mode = vim.fn.mode()
	local in_select_mode = mode == "v" or mode == "V" or mode == "^V" or mode == "s"

	if not in_select_mode then
		print("not in select mode")
		return nil
	end

	-- FIX: these are only set after leaving select mode for some reason
	local ps = vim.fn.getpos("'<")
	local pe = vim.fn.getpos("'>")
	print(vim.inspect(ps), vim.inspect(pe))

	if (ps[2] == pe[2]) and (ps[3] + 1 ~= pe[3]) then
		print("detected single line selection")
		local line = vim.api.nvim_buf_get_lines(0, ps[2] - 1, ps[2], true)[1]
		return { string.sub(line, ps[3], pe[3] - 1) }
	elseif ps[2] ~= pe[2] then
		print("detected multiline line selection")
		local lines = vim.api.nvim_buf_get_lines(0, ps[2] - 1, pe[2], false)
		lines[1] = string.sub(lines[1], ps[3])
		lines[#lines] = string.sub(lines[#lines], 1, pe[3] - 1)
		return lines
	else
		print("detected no selection")
		return nil
	end
end

function M.starts_with(str, start)
	return (string.sub(str, 1, string.len(start)) == start)
end

return M
