--Glitchy Helper
TOKEN_GLITCHY_HELPER					= 1232
GLITCHY_HELPER_TURN_COUNT_FLAG			= 0x1

function Card.IsNonPlayableCard(c)
	return c:HasFlagEffect(TOKEN_GLITCHY_HELPER)
end

local _IsExistingMatchingCard, _IsExistingTarget, _GetMatchingGroup, _GetMatchingGroupCount, _SelectMatchingCard, _SelectTarget, _GetFieldGroup, _GetFieldGroupCount
=
Duel.IsExistingMatchingCard, Duel.IsExistingTarget, Duel.GetMatchingGroup, Duel.GetMatchingGroupCount, Duel.SelectMatchingCard, Duel.SelectTarget, Duel.GetFieldGroup, Duel.GetFieldGroupCount

Duel.IsExistingMatchingCard = function(f,pov,l1,l2,min,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _IsExistingMatchingCard(f,pov,l1,l2,min,g,...)
	else
		return _IsExistingMatchingCard(f,pov,l1,l2,min,exc,...)
	end
end
Duel.IsExistingTarget = function(f,pov,l1,l2,min,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _IsExistingTarget(f,pov,l1,l2,min,g,...)
	else
		return _IsExistingTarget(f,pov,l1,l2,min,exc,...)
	end
end
Duel.GetMatchingGroup = function(f,pov,l1,l2,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _GetMatchingGroup(f,pov,l1,l2,g,...)
	else
		return _GetMatchingGroup(f,pov,l1,l2,exc,...)
	end
end
Duel.GetMatchingGroupCount = function(f,pov,l1,l2,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _GetMatchingGroupCount(f,pov,l1,l2,g,...)
	else
		return _GetMatchingGroupCount(f,pov,l1,l2,exc,...)
	end
end
Duel.SelectMatchingCard = function(p,f,pov,l1,l2,min,max,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _SelectMatchingCard(p,f,pov,l1,l2,min,max,g,...)
	else
		return _SelectMatchingCard(p,f,pov,l1,l2,min,max,exc,...)
	end
end
Duel.SelectTarget = function(p,f,pov,l1,l2,min,max,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=aux.GetValueType(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _SelectTarget(p,f,pov,l1,l2,min,max,g,...)
	else
		return _SelectTarget(p,f,pov,l1,l2,min,max,exc,...)
	end
end
Duel.GetFieldGroup = function(pov,l1,l2)
	local g0=_GetFieldGroup(pov,l1,l2)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		g0:Sub(g)
	end
	return g0
end
Duel.GetFieldGroupCount = function(pov,l1,l2)
	local ct0=_GetFieldGroupCount(pov,l1,l2)
	local ct=_GetMatchingGroupCount(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	return ct0-ct
end

Auxiliary.GlitchyHelperIgnorePlayerTable={false,false}
function Auxiliary.SpawnGlitchyHelper(flags)
	if not aux.GlitchyHelper then
		aux.GlitchyHelper=1
		local e=Effect.GlobalEffect()
		e:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e:SetCode(EVENT_ADJUST)
		e:SetCountLimit(1)
		e:SetOperation(function(eff)
			aux.GlitchyHelper=Duel.CreateToken(0,TOKEN_GLITCHY_HELPER)
			Duel.Banish(aux.GlitchyHelper,nil,REASON_RULE)
			aux.GlitchyHelper:RegisterFlagEffect(TOKEN_GLITCHY_HELPER,0,0,1)
			local e4=Effect.CreateEffect(aux.GlitchyHelper)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			e4:SetCode(EFFECT_IMMUNE_EFFECT)
			e4:SetValue(function(ef,te)
				return te:GetOwner()~=ef:GetOwner()
			end)
			aux.GlitchyHelper:RegisterEffect(e4)
			
			aux.GlitchyHelperFlags=0
			for p=0,1 do
				local res=Duel.SelectYesNo(p,STRING_EXCLUDE_AI)
				if not res then
					aux.GlitchyHelperIgnorePlayerTable[p+1]=true
				end
			end
			aux.SpawnGlitchyHelper(flags)
			eff:Reset()
		end
		)
		Duel.RegisterEffect(e,0)
		
	elseif aux.GetValueType(aux.GlitchyHelper)=="Card" then
		if flags&GLITCHY_HELPER_TURN_COUNT_FLAG>0 and aux.GlitchyHelperFlags&GLITCHY_HELPER_TURN_COUNT_FLAG==0 then
			aux.GlitchyHelperFlags = aux.GlitchyHelperFlags|GLITCHY_HELPER_TURN_COUNT_FLAG
			for p=0,1 do
				if aux.GlitchyHelperIgnorePlayerTable[p+1]==false then
					local h1=Effect.CreateEffect(aux.GlitchyHelper)
					h1:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
					h1:SetCode(EVENT_FREE_CHAIN)
					h1:SetCountLimit(50)
					h1:SetOperation(aux.GlitchyHelperTurnCount)
					Duel.RegisterEffect(h1,p)
				end
			end
		end
	end
end
function Auxiliary.GlitchyHelperTurnCount(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTurnCount(nil,true)
	if ct<=20 and ct>0 then
		e:GetOwner():SetTurnCounter(ct)
	else
		Duel.Hint(HINT_CARD,tp,TOKEN_GLITCHY_HELPER)
		Duel.AnnounceNumber(tp,ct)
	end
	Duel.SetChainLimit(aux.FALSE)
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end