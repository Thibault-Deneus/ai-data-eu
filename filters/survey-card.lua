-- Builds the top of every survey page from its YAML header:
-- a source link, then a short fact table (who / when / where / sample / question).
-- Pages without a `who` field (the overview) are left untouched.

local function html(v)
  if v == nil or type(v) == "boolean" then return nil end
  local doc
  if pandoc.utils.type(v) == "Inlines" then
    doc = pandoc.Pandoc({ pandoc.Plain(v) })
  elseif pandoc.utils.type(v) == "Blocks" then
    doc = pandoc.Pandoc(v)
  else
    doc = pandoc.Pandoc({ pandoc.Plain({ pandoc.Str(pandoc.utils.stringify(v)) }) })
  end
  local out = pandoc.write(doc, "html"):gsub("^<p>", ""):gsub("</p>%s*$", "")
  if out == "" then return nil end
  return out
end

local pills = { workers = "pill-workers", firms = "pill-firms", individuals = "pill-individuals" }

function Pandoc(doc)
  local m = doc.meta
  if not m.who then return doc end

  local rows = {}
  local function row(label, value)
    if value and value ~= "" then
      rows[#rows + 1] = "<dt>" .. label .. "</dt><dd>" .. value .. "</dd>"
    end
  end

  row("Who", html(m.who))
  row("When", html(m.when))
  row("Where", html(m.where))

  if m.asked then
    local label = pandoc.utils.stringify(m.asked)
    local cls = pills[label:lower()] or "pill-both"
    local sample = '<span class="pill ' .. cls .. '">' .. label .. "</span>"
    if m.sample then sample = sample .. html(m.sample) end
    row("Sample", sample)
  end

  row("Question", html(m.question))

  -- Does the survey measure AI adoption by workers and/or by firms?
  local adoption = {}
  if m["adoption-individuals"] then adoption[#adoption + 1] = "Individuals: " .. pandoc.utils.stringify(m["adoption-individuals"]) .. "%" end
  if m["adoption-workers"] then
    local text = "Workers: " .. pandoc.utils.stringify(m["adoption-workers"]) .. "%"
    if m["adoption-base"] then text = text .. " (" .. html(m["adoption-base"]) .. ")" end
    adoption[#adoption + 1] = text
  end
  if m["adoption-firms"] then
    local text = "Firms: " .. pandoc.utils.stringify(m["adoption-firms"]) .. "%"
    if m["adoption-firms-base"] then text = text .. " (" .. html(m["adoption-firms-base"]) .. ")" end
    adoption[#adoption + 1] = text
  end
  if m["adoption-text"] then adoption = { html(m["adoption-text"]) } end
  row("Adoption", #adoption > 0 and table.concat(adoption, " &middot; ") or "No adoption question")

  local out = {}
  if m.link then
    local url = pandoc.utils.stringify(m.link)
    local text = m["link-text"] and html(m["link-text"]) or url
    out[#out + 1] = '<p class="survey-link"><a href="' .. url .. '" target="_blank" rel="noopener">' .. text .. "</a></p>"
  end
  out[#out + 1] = '<dl class="survey-card">\n' .. table.concat(rows, "\n") .. "\n</dl>"
  if m.aim then
    out[#out + 1] = '<p class="survey-aim"><strong>Main aim.</strong> ' .. html(m.aim) .. "</p>"
  end

  table.insert(doc.blocks, 1, pandoc.RawBlock("html", table.concat(out, "\n")))
  return doc
end
