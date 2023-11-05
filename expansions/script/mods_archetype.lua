Auxiliary.SetCardOrigFuns={}
Auxiliary.PreviousSetStrs={}
CUSTOM_ARCHETYPES_STR={
	[""]={},
	["Original"]={},
	["Previous"]={},
	["Fusion"]={},
	["Link"]={}
}
function Card.CheckCustomSetValue(c,e,s,k)
	local v=e:GetValue()
	local typ=type(v)
	if typ=="function" then
		local r=v(e,c)
		local rt=type(r)
		if rt=="string" then return r==s
		elseif rt=="table" then
			return aux.FindInTable(rt,s)
		else
			return aux.SetCardOrigFuns["Card.Is"..k.."SetCard"](c,r)
		end
	else return false end
end
function Card.CheckCustomSetCard(c,s,k)
	local typ=type(s)
	if typ=="number" then
		return aux.SetCardOrigFuns["Card.Is"..k.."SetCard"](c,s)
	elseif typ=="string" then
		CUSTOM_ARCHETYPES_STR[k][s]=CUSTOM_ARCHETYPES_STR[k][s] or {["C"]={}}
		local et={
			[""]={c:IsHasEffect(EFFECT_ADD_SETCODE)},
			["Fusion"]={c:IsHasEffect(EFFECT_ADD_FUSION_SETCODE)},
			["Link"]={c:IsHasEffect(EFFECT_ADD_LINK_SETCODE)}
		}
		if k=="Previous" then
			aux.PreviousSetStrs[c]=aux.PreviousSetStrs[c] or {}
			for _,set in ipairs(aux.PreviousSetStrs[c]) do
				if type(set)=="table" then
					if aux.FindInTable(set,s) then return true end
				elseif s==set then return true end
			end
		else for _,e in ipairs(et[k]) do
			if c:CheckCustomSetValue(e,s,k) then return true end
		end end
		local f=CUSTOM_ARCHETYPES_STR[k][s]["F"]
		for _,code in ipairs(CUSTOM_ARCHETYPES_STR[k][s]["C"]) do
			if k=="Original" then
				if aux.FindInTable({c:GetOriginalCodeRule()},code) then
					return f(c)
				end
			elseif k=="Previous" then
				if code==c:GetPreviousCodeOnField() then return f(c) end
			elseif Card["Get"..k.."Code"](c)==code then
				return f(c)
			end
		end
	end
	return false
end
function Auxiliary.GetPreSetCardStrs(e,tp,eg)
	for c in aux.Next(eg) do
		local st={c:IsHasEffect(EFFECT_ADD_SETCODE)}
		if #st>0 then
			aux.PreviousSetStrs[c]={}
			for _,e in ipairs(st) do if not (c:IsForbidden() or c:IsDisabled()) or e:GetOwner()~=c or e:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE) then
				local v=e:GetValue()
				if type(v)=="function" then
					local s=v(e,c)
					local typ=type(s)
					if typ=="string" or typ=="table" then
						table.insert(aux.PreviousSetStrs[c],s)
					end
				end
			end end
		end
	end
end
function Card.RegisterSetCardString(c,...)
	--... format:
	--	archetype: string (use a table of strings and/or hex numbers as follows for subarchetype-strings: {main, sub1, sub2, ... subN})
	--	condition: function (use aux.FALSE if adding an archetype-string to another card, e.g. via effect)
	--Note: Archetype-strings added by effects should be enclosed in a function; Effect.SetValue converts strings into the integer 0, otherwise!
	if getmetatable(c).global_check then return end
	getmetatable(c).global_check=true
	local t={...}
	for kind in pairs(CUSTOM_ARCHETYPES_STR) do
		local fn="Is"..kind.."SetCard"
		Auxiliary.SetCardOrigFuns["Card."..fn]=Auxiliary.SetCardOrigFuns["Card."..fn] or Card[fn]
		Card[fn]=function(c,...)
			local result=false
			for _,s in ipairs{...} do
				local typ=type(s)
				if typ=="table" then
					local res=true
					for _,set in ipairs(s) do
						res=res and c:CheckCustomSetCard(set,kind)
					end
					result=result or res
				else
					result=result or c:CheckCustomSetCard(s,kind)
				end
			end
			return result
		end
		for i=1,#t do
			c:AddSetCardStr(t[i],i<#t and t[i+1],kind)
		end
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD_P)
	e1:SetOperation(aux.GetPreSetCardStrs)
	Duel.RegisterEffect(e1,0)
end
function Card.AddSetCardStr(c,s,f,k)
	local t=type(s)
	if type(f)~="function" then f=aux.TRUE end
	if t=="function" then return end
	if t=="string" then
		CUSTOM_ARCHETYPES_STR[k][s]=CUSTOM_ARCHETYPES_STR[k][s] or {["C"]={}}
		for _,id in ipairs{c:GetOriginalCodeRule()} do
			table.insert(CUSTOM_ARCHETYPES_STR[k][s]["C"],id)
		end
		CUSTOM_ARCHETYPES_STR[k][s]["F"]=f
	end
	if t=="table" then
		local base=s[1]
		if type(base)=="number" then
			f=aux.AND(f,aux.FilterBoolFunction(aux.SetCardOrigFuns["Card.Is"..k.."SetCard"],base))
		end
		for i=2,#s do
			c:AddSetCardStr(s[i],f,k)
		end
	end
end

