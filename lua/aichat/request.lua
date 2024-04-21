local M = {}

local chat = require("aichat.chat")
local curl = require("plenary.curl")

function M.build_body(messages, model)
	return {
		messages = messages,
		model = model,
	}
end

function M.execute_request(url, body, auth, timeout_s)
	local response = curl.post(url, {
		timeout = timeout_s * 1000,
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = "Bearer " .. auth,
		},
		body = vim.json.encode(body),
	})

	if response.status == 200 then
		return response.body
	else
		vim.lua_error("API call failed with - status: ", response.status, " and body: ", response.body)
	end
end

function M.extract_response_content(response)
	-- TODO: check this somehow?
	return vim.json.decode(response).choices[1].message.content
end

function M.trigger_completion(options, buf)
	local messages = chat.parse_buffer(buf, options)
	local body = M.build_body(messages, options.ai_model)
	local response = M.execute_request(options.api_url, body, options.api_auth, options.request_timeout_s)
	local text = M.extract_response_content(response)
	vim.api.nvim_buf_set_option(buf, "modifiable", true)
	chat.insert_response(text, buf, options.assistant_tag, options.user_tag)
end

return M
