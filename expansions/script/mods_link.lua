EFFECT_UPDATE_LINK_RATING_GLITCHY	= 100000376

local _LExtraMaterialCount, _GetLink, _IsLink, _IsLinkAbove, _IsLinkBelow = Auxiliary.LExtraMaterialCount, Card.GetLink, Card.IsLink, Card.IsLinkAbove, Card.IsLinkBelow

--Implement Link Rating modification effects
function Card.GetLink(c)
	local ct=_GetLink(c)
	
	if aux.EnableLinkRatingMods then
		local eset={c:IsHasEffect(EFFECT_UPDATE_LINK_RATING_GLITCHY)}
		if #eset>0 then
			table.sort(eset,aux.EffectSort)
			for _,e in ipairs(eset) do
				local val=e:Evaluate(c)
				ct=ct+val
			end
		end
	end
	
	return math.max(1,ct)
end
function Card.IsLink(c,val1,...)
	if not aux.EnableLinkRatingMods then
		return _IsLink(c,val1,...)
	end
	local vals={...}
	table.insert(vals,val1)
	for _,val in ipairs(vals) do
		if c:GetLink()==val then
			return true
		end
	end
	return false
end
function Card.IsLinkAbove(c,v)
	if not aux.EnableLinkRatingMods then
		return _IsLinkAbove(c,v)
	end
	local lk=c:GetLink()
	return lk~=0 and lk>=v
end
function Card.IsLinkBelow(c,v)
	if not aux.EnableLinkRatingMods then
		return _IsLinkBelow(c,v)
	end
	local lk=c:GetLink()
	return lk~=0 and lk<=v
end

--Add call to an operation function for EFFECT_EXTRA_LINK_MATERIAL when they are used
function Auxiliary.LExtraMaterialCount(mg,lc,tp)
	if not aux.AllowExtraLinkMaterialOperation then
		_LExtraMaterialCount(mg,lc,tp)
	else
		for tc in Auxiliary.Next(mg) do
			local le={tc:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
			for _,te in pairs(le) do
				local sg=mg:Filter(Auxiliary.TRUE,tc)
				local f=te:GetValue()
				local related,valid=f(te,lc,sg,tc,tp)
				if related and valid then
					te:UseCountLimit(tp)
					local op=te:GetOperation()
					if op then
						op(te,tp,lc,mg,sg,tc)
					end
				end
			end
		end
	end
end