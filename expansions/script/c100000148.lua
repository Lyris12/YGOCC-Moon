--[[
Cerulean Sea Siren
Sirena del Mare Cerulea
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,5,s.TLcon,{s.TLfilter,true})
	c:EnableReviveLimit()
	--[[If you Time Leap Summon this card, you must Summon it to an Extra Monster Zone, or to a zone a Link Monster points to.]]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_MUST_USE_MZONE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.frcval)
	c:RegisterEffect(e0)
	--[[If this card is Time Leap Summoned: You can change all monsters on the field to face-down Defense Position.
	If your opponent controls 4 or more cards than you do, they cannot activate monster effects in response to this effect's activation.
	Monsters changed to face-down Defense Position by this effect cannot change their battle position, until the end of the next turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.TimeleapSummonedCond,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		local _IsCanBeSpecialSummoned, _SpecialSummon, _SpecialSummonStep = Card.IsCanBeSpecialSummoned, Duel.SpecialSummon, Duel.SpecialSummonStep
		
		Card.IsCanBeSpecialSummoned=function(c,e,sumtype,rp,ign1,ign2,...)
			if sumtype==SUMMON_TYPE_TIMELEAP then
				local x={...}
				local pos  = #x>0 and x[1] or POS_FACEUP
				local up   = #x>1 and x[2] or rp
				local zone = #x>2 and x[3] or 0xff
				if zone==0xff then
					zone=0xffff
				end
				c:RegisterFlagEffect(FLAG_CERULEAN_SEA_SIREN,0,0,1)
				local res=_IsCanBeSpecialSummoned(c,e,sumtype,rp,ign1,ign2,pos,up,zone)
				c:ResetFlagEffect(FLAG_CERULEAN_SEA_SIREN)
				return res
			else
				return _IsCanBeSpecialSummoned(c,e,sumtype,rp,ign1,ign2,...)
			end
		end
		
		Duel.SpecialSummon=function(g,sumtype,rp,tp,ign1,ign2,pos,...)
			if sumtype==SUMMON_TYPE_TIMELEAP then
				if aux.GetValueType(g)=="Card" then
					g:RegisterFlagEffect(FLAG_CERULEAN_SEA_SIREN,0,0,1)
				else
					for tc in aux.Next(g) do
						tc:RegisterFlagEffect(FLAG_CERULEAN_SEA_SIREN,0,0,1)
					end
				end
			end
			local ct=_SpecialSummon(g,sumtype,rp,tp,ign1,ign2,pos,...)
			if aux.GetValueType(g)=="Card" then
				g:RegisterFlagEffect(FLAG_CERULEAN_SEA_SIREN,0,0,1)
			else
				for tc in aux.Next(g) do
					tc:ResetFlagEffect(FLAG_CERULEAN_SEA_SIREN)
				end
			end
			return ct
		end
		
		Duel.SpecialSummonStep=function(c,sumtype,rp,tp,ign1,ign2,pos,...)
			if sumtype==SUMMON_TYPE_TIMELEAP then
				c:RegisterFlagEffect(FLAG_CERULEAN_SEA_SIREN,0,0,1)
			end
			local ct=_SpecialSummonStep(c,sumtype,rp,tp,ign1,ign2,pos,...)
			c:ResetFlagEffect(FLAG_CERULEAN_SEA_SIREN)
			return ct
		end
	end
end
function s.TLcon(e,c,tp)
	return Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_ONFIELD|LOCATION_HAND,nil) > Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil)
end
function s.TLfilter(c,e,mg,tl)
	return c:IsSummonType(SUMMON_TYPE_NORMAL) and (c:IsLevelBelow(3) or c:IsLevel(tl:GetFuture()-1))
end

--E0
function s.frcval(e,c,fp,rp,r)
	local tp=c:GetControler()
	if c:HasFlagEffect(FLAG_CERULEAN_SEA_SIREN) then
		return Duel.GetLinkedZone(tp)|(Duel.GetLinkedZone(1-tp)<<16)|0x600060
	else
		return 0xff
	end
end

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSetGlitchy,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSetGlitchy,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,PLAYER_ALL,LOCATION_MZONE)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD) >= 4+Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,ep,tp)
	return ep==tp or not e:IsActiveType(TYPE_MONSTER)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSetGlitchy,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)>0 then
		local c=e:GetHandler()
		local og=Duel.GetOperatedGroup():Filter(Card.IsPosition,nil,POS_FACEDOWN_DEFENSE)
		for tc in aux.Next(og) do
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_CANNOT_CHANGE_POSITION)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,2)
			tc:RegisterEffect(e1)
		end
	end
end