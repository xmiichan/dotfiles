-- pandoc custom writer: FFML-style plain text (72 columns, mail-safe)
--
--   pandoc -t ffml.lua story.md -o story.txt
--
-- Options (-M):
--   width=72        maximum line width
--   indent=8        number of spaces, or "tab" for a literal TAB

local pandoc = require("pandoc")

local layout = pandoc.layout
local literal, concat, blankline, cr = layout.literal, layout.concat,
	layout.blankline, layout.cr
local len = pandoc.text.len

Writer = pandoc.scaffolding.Writer

local WIDTH = 72
local INDENT_WIDTH = 8
local INDENT = string.rep(" ", INDENT_WIDTH)

local PUNCTUATION = {
	["\u{2018}"] = "'",
	["\u{2019}"] = "'",
	["\u{201C}"] = '"',
	["\u{201D}"] = '"',
	["\u{2013}"] = "--",
	["\u{2014}"] = "--",
	["\u{2026}"] = "...",
	["\u{00A0}"] = " ",
	["\u{2212}"] = "-",
	["\u{00AD}"] = "",
}

local function plain(s)
	for k, v in pairs(PUNCTUATION) do
		s = s:gsub(k, v)
	end
	return s
end

local function center(s, width)
	local pad = math.floor(((width or WIDTH) - len(s)) / 2)
	return string.rep(" ", math.max(pad, 0)) .. s
end

local function fill(s, first_prefix, first_width, width)
	local out, line, prefix, limit = {}, nil, first_prefix, first_width
	for word in s:gmatch("%S+") do
		if not line then
			line = prefix .. word
		elseif len(line) + 1 + len(word) <= limit then
			line = line .. " " .. word
		else
			out[#out + 1] = line
			line, prefix, limit = word, "", width
		end
	end
	out[#out + 1] = line or ""
	return out
end

local function flatten(inlines, opts)
	return layout.render(Writer.Inlines(inlines), 10 ^ 6)
end

local function nested(width, indent, fn)
	local w, i, iw = WIDTH, INDENT, INDENT_WIDTH
	WIDTH, INDENT, INDENT_WIDTH = width, indent, len(indent)
	local ok, res = pcall(fn)
	WIDTH, INDENT, INDENT_WIDTH = w, i, iw
	if not ok then
		error(res)
	end
	return res
end

local function block(lines)
	local docs = {}
	for i, l in ipairs(lines) do
		docs[#docs + 1] = literal(l)
		if i < #lines then
			docs[#docs + 1] = cr
		end
	end
	return concat({ concat(docs), blankline })
end

-- paragraphs: first line indented, rest flush, hard breaks preserved
local function paragraph(inlines, opts, first_prefix, indent_width)
	local lines = {}
	local text = flatten(inlines, opts)
	local first = true

	for seg in (text .. "\n"):gmatch("([^\n]*)\n") do
		local prefix = first and first_prefix or ""
		local fw = WIDTH - (first and indent_width or 0)
		for _, l in ipairs(fill(seg, prefix, fw + len(prefix), WIDTH)) do
			lines[#lines + 1] = l
		end
		first = false
	end

	return lines
end

Writer.Block.Para = function(el, opts)
	return block(paragraph(el.content, opts, INDENT, INDENT_WIDTH))
end

Writer.Block.Plain = function(el, opts)
	return block(paragraph(el.content, opts, "", 0))
end

-- splits headings on colon
-- "Chapter 1: A Quiet Room" becomes
--        Chapter 1
--      A Quiet Room
local function split_heading(s)
	local label, title = s:match("^%s*(%S.-)%s*:%s+(%S.*)$")
	return label and label, title or nil
end

Writer.Block.Header = function(el, opts)
	local body = flatten(el.content, opts)
	if el.level == 1 then
		body = pandoc.text.upper(body)
	end
	local parts = { body }
	local label, title = split_heading(body)
	if label then
		parts = { label, title }
	end
	local lines = {}
	for _, part in ipairs(parts) do
		for _, l in ipairs(fill(part, "", WIDTH, WIDTH)) do
			lines[#lines + 1] = center(l)
		end
	end
	return block(lines)
end

Writer.Block.HorizontalRule = function()
	return block({ center("* * *") })
end

Writer.Block.BlockQuote = function(el, opts)
	local lines = {}
	local inner = nested(WIDTH - 8, "", function()
		return layout.render(Writer.Blocks(el.content), WIDTH)
	end)
	for line in (inner .. "\n"):gmatch("([^\n]*)\n") do
		lines[#lines + 1] = (line == "" and "" or "        " .. line)
	end
	while lines[#lines] == "" do
		table.remove(lines)
	end
	return block(lines)
end

Writer.Block.CodeBlock = function(el)
	local lines = {}
	for line in (el.text .. "\n"):gmatch("([^\n]*)\n") do
		lines[#lines + 1] = (line == "" and "" or "    " .. line)
	end
	return block(lines)
end

local function list(el, opts, marker)
	local lines = {}
	for i, item in ipairs(el.content) do
		local m = marker(i)
		local body = nested(WIDTH - len(m), "", function()
			return layout.render(Writer.Blocks(item), WIDTH)
		end)
		local first = true
		for line in (body .. "\n"):gmatch("([^\n]*)\n") do
			if first then
				lines[#lines + 1] = m .. line
				first = false
			else
				lines[#lines + 1] = (line == "" and "" or string.rep(" ", len(m)) .. line)
			end
		end
		while lines[#lines] == "" do
			table.remove(lines)
		end
	end
	return block(lines)
end

Writer.Block.BulletList = function(el, opts)
	return list(el, opts, function()
		return "  * "
	end)
end

Writer.Block.OrderedList = function(el, opts)
	local n = el.start or 1
	return list(el, opts, function(i)
		return string.format("  %d. ", n + i - 1)
	end)
end

Writer.Block.Div = function(el, opts)
	return Writer.Blocks(el.content)
end

Writer.Block.RawBlock = function()
	return layout.empty
end

Writer.Block.LineBlock = function(el, opts)
	local lines = {}
	for _, l in ipairs(el.content) do
		lines[#lines + 1] = flatten(l, opts)
	end
	return block(lines)
end

Writer.Inline.Str = function(el)
	return literal(plain(el.text))
end
Writer.Inline.Space = layout.space
Writer.Inline.SoftBreak = layout.space
Writer.Inline.LineBreak = cr
Writer.Inline.Code = function(el)
	return literal(el.text)
end
Writer.Inline.RawInline = function()
	return layout.empty
end

local function around(open, close)
	return function(el, opts)
		return concat({
			literal(open),
			Writer.Inlines(el.content),
			literal(close),
		})
	end
end

Writer.Inline.Strong = around("*", "*")
Writer.Inline.Emph = around("/", "/")
Writer.Inline.Underline = around("_", "_")
Writer.Inline.Strikeout = around("-", "-")

Writer.Inline.SmallCaps = function(el, opts)
	return literal(pandoc.text.upper(flatten(el.content, opts)))
end

Writer.Inline.Quoted = function(el, opts)
	local q = el.quotetype == "SingleQuote" and "'" or '"'
	return around(q, q)(el, opts)
end

Writer.Inline.Link = function(el, opts)
	local body = Writer.Inlines(el.content)
	if el.target:match("^%a+:") or el.target:match("^www%.") then
		return concat({ body, literal(" <" .. el.target .. ">") })
	end
	return body
end

Writer.Inline.Image = function(el, opts)
	return concat({ literal("[image: "), Writer.Inlines(el.caption), literal("]") })
end

Writer.Inline.Span = function(el, opts)
	for _, c in ipairs(el.classes) do
		if c == "underline" then
			return around("_", "_")(el, opts)
		end
	end
	return Writer.Inlines(el.content)
end

Writer.Inline.Note = function(el, opts)
	return concat({ literal(" ["), Writer.Blocks(el.content), literal("]") })
end

Writer.Pandoc = function(doc, opts)
	local meta = doc.meta

	if meta.width then
		WIDTH = math.tointeger(tonumber(pandoc.utils.stringify(meta.width))) or
			WIDTH
	end

	if meta.indent then
		local v = pandoc.utils.stringify(meta.indent)
		local n = tonumber(v)
		if n then
			INDENT, INDENT_WIDTH = string.rep(" ", n), n
		elseif v == "tab" then
			INDENT, INDENT_WIDTH = "\t", 8
		end
	end

	local head = {}
	if meta.title then
		local texts = { pandoc.text.upper(plain(pandoc.utils.stringify(meta
			.title))) }

		if meta.author then
			local authors = {}
			for _, a in ipairs(pandoc.utils.type(meta.author) == "List" and meta.author or { meta.author }) do
				authors[#authors + 1] = plain(pandoc.utils.stringify(a))
			end
			texts[#texts + 1] = "by " .. table.concat(authors, ", ")
		end

		local widest = 0
		for _, t in ipairs(texts) do
			widest = math.max(widest, len(t))
		end
		texts[#texts + 1] = string.rep("=", math.min(widest + 2, WIDTH))

		for _, t in ipairs(texts) do
			head[#head + 1] = center(t)
		end
	end

	local body = Writer.Blocks(doc.blocks)
	if #head == 0 then
		return body
	end

	return concat({ block(head), body })
end
