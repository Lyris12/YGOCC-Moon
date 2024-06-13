local _LExtraMaterialCount = Auxiliary.LExtraMaterialCount

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