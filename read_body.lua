--[[
/**
 * read_body.lua
 *
 * @authors guanhua2011 (guanhua2011@gmail.com)
 * @version 1.0
 */
]]

--lua func
local type = type
local string = string
local table = table
local pairs = pairs
local next = next

--ngx module
local ngx_req = ngx.req

module(...)

--[[
/**
 * 分隔字符串
 *
 * @param string delimiter	分隔表示符
 * @param string str		带分隔字符串
 * @return table | nil
 */
]]
function explode(delimiter, str)
	if type(delimiter) ~= 'string' or type(str) ~= 'string' then 
		return nil
	end
	local t, pos, len = {}, 1, #delimiter
	repeat 
		pos = string.find(str, delimiter, 1, true)
		if pos then
			table.insert(t, string.sub(str, 1, pos -1))
			str = string.sub(str, pos + len)
		end
	until(not pos)
	if str and #str > 0 then
		table.insert(t, str)
	end
	return t
end

--获取boundary
local function get_boundary()
    local header = ngx_req.get_headers()["content-type"]
    if not header then
        return nil
    end 
        
    if type(header) == "table" then
        header = header[1]
    end         

    local m = string.match(header, ";%s*boundary=\"([^\"]+)\"")
    if m then
        return m
    end

    return string.match(header, ";%s*boundary=([^\",;]+)")
end

--获取body table
function getBodyData()
	local data = {}
	local boundary = get_boundary()
	local post = ngx_req.get_post_args()
	if type(post) == 'table' and next(post) then
		if not boundary then
			return post
		end
		data = post
		post = ngx_req.get_body_data()
		if type(post) == 'string' then
			data = {}
			post = explode(boundary, post)
			if type(post) == 'table' and next(post) then
				for __, v in pairs(post) do
					local tmp = explode("\r\n\r\n", v)
					if type(tmp) == 'table' and tmp[2] then
						local name = string.match(tmp[1], "name=\"([^\"]+)\"") or tmp[1]
						local t = Utils.explode("\r\n",tmp[2])
					    data[name] = t[1] or tmp[2]
				    end
				end
			end
		end
	end
	return data
end
