--[[
ZERO//OVER
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_POWER_VACUUM_BLADE,CARD_POWER_VACUUM_ZONE,CARD_VACUOUS_NIGHTMARE_ZERO_HORIZON)
	--[[At the start of your Battle Phase, if you control "Power Vacuum Blade", "Power Vacuum Zone", and "Vacuous Nightmare - ZERO HORIZON": Banish 1 "Power Vacuum Blade" and "Power Vacuum Zone" you
	control, and if you do, 1 "Vacuous Nightmare - ZERO HORIZON" you control gains ATK/DEF equal to the total number of banished cards x 1000, also, immediately after this effect resolves, shuffle as
	many cards from the field, GYs, and banishment into the Decks as possible, except this card and "Vacuous Nightmare - ZERO HORIZON".]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORIES_ATKDEF|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_START)
	e1:HOPT(true)
	e1:SetFunctions(
		s.condition,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
end

--E1
function s.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_POWER_VACUUM_BLADE,CARD_POWER_VACUUM_ZONE) and c:IsAbleToRemove()
end
function s.pairfilter(c1,c2)
	return c1:IsCode(CARD_POWER_VACUUM_BLADE) and c2:IsCode(CARD_POWER_VACUUM_ZONE)
end
function s.gcheck(atkg)
	return	function(g,e,tp,mg,c)
				if #g==1 then return true end
				local c1,c2=g:GetFirst(),g:GetNext()
				return (s.pairfilter(c1,c2) or s.pairfilter(c2,c1)) and (not atkg or atkg:IsExists(aux.TRUE,1,g))
			end
end
		
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsStartOfBattlePhase(tp)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil,CARD_POWER_VACUUM_BLADE)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil,CARD_POWER_VACUUM_ZONE)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil,CARD_VACUOUS_NIGHTMARE_ZERO_HORIZON)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.Group(s.rmfilter,tp,LOCATION_ONFIELD,0,nil)
	local atkg=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil,CARD_VACUOUS_NIGHTMARE_ZERO_HORIZON)
	if chk==0 then
		return #atkg>0 and aux.SelectUnselectGroup(rg,e,tp,2,2,s.gcheck(atkg),0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,2,0,0)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,atkg,1,0,0,(Duel.GetBanishmentCount()+2)*1000)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_ONFIELD|LOCATION_GB)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(s.rmfilter,tp,LOCATION_ONFIELD,0,nil)
	local atkg=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil,CARD_VACUOUS_NIGHTMARE_ZERO_HORIZON)
	if #atkg==0 then atkg=nil end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck(atkg),1,tp,HINTMSG_REMOVE)
	if #rg==2 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)==2 then
		local val=Duel.GetBanishmentCount()*1000
		if val>0 then
			local atkg=Duel.Select(HINTMSG_FACEUP,false,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,CARD_VACUOUS_NIGHTMARE_ZERO_HORIZON)
			if Duel.Highlight(atkg) then
				atkg:GetFirst():UpdateATKDEF(val,val,true,{c,true})
			end
		end
	end
	if c:IsRelateToChain() then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_PHASE_END,0,1)
	end
	aux.ApplyEffectImmediatelyAfterResolution(s.tdop,c,e,tp,eg,ep,ev,re,r,rp)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp,_e,isChainEnd)
	local c=e:GetHandler()
	local g=Duel.Group(aux.Necro(s.tdfilter),tp,LOCATION_ONFIELD|LOCATION_GB,LOCATION_ONFIELD|LOCATION_GB,nil)
	if c:HasFlagEffect(id) then
		g:AddCard(c)
	end
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,tp,true)
	end
end
function s.tdfilter(c)
	return (not c:IsCode(CARD_VACUOUS_NIGHTMARE_ZERO_HORIZON) or not c:IsFaceup()) and c:IsAbleToDeck()
end