--[[
Number iC210: Archfiend of Verdanse
Numero iC210: Arcidemone di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
if not GLITCHYCORE_LOADED then
	Duel.LoadScript("glitchylib_core.lua")
end
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),6,3)
	aux.AddCodeList(c,CARD_NUMBER_I209_FALLEN_OF_VERDANSE)
	--Must first be Xyz Summoned.
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SINGLE_RANGE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.xyzlimit)
	c:RegisterEffect(e0)
	--[[If this card is Xyz Summoned: You can make your opponent reveal 3 random face-down cards in their Extra Deck; for the rest of this turn and for the next 3 turns after this effect resolves, 
	each time your opponent Special Summons a monster(s) with the same name as any of the revealed cards, they take damage equal to the total ATK or DEF of those Special Summoned monsters 
	(for each monster choose whichever one is higher, or its ATK if tied).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[((Quick Effect): You can detach 1 material from a DARK Xyz Monster you control; shuffle 1 card on the field into the Deck,
	or if this card has "Number i209: Fallen of Verdanse" as material, banish it face-down.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		nil,
		s.tdcost,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2)
end
aux.xyz_number[id]=210

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return #g>2 end
	local rg=g:RandomSelect(1-tp,3)
	Duel.ConfirmCards(tp,rg)
	Duel.ConfirmCards(1-tp,rg)
	local codes={}
	for tc in aux.Next(rg) do
		local tab={tc:GetCode()}
		for _,code in ipairs(tab) do
			table.insert(codes,code)
		end
	end
	e:SetLabel(table.unpack(codes))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local codes={e:GetLabel()}
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetLabel(table.unpack(codes))
	e4:SetCondition(s.drcon1)
	e4:SetOperation(s.drop1)
	e4:SetReset(RESET_PHASE|PHASE_END,4)
	Duel.RegisterEffect(e4,tp)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetLabel(table.unpack(codes))
	e5:SetCondition(s.regcon)
	e5:SetOperation(s.regop)
	e5:SetReset(RESET_PHASE|PHASE_END,4)
	Duel.RegisterEffect(e5,tp)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetLabel(table.unpack(codes))
	e6:SetCondition(s.drcon2)
	e6:SetOperation(s.drop2)
	e6:SetReset(RESET_PHASE|PHASE_END,4)
	Duel.RegisterEffect(e6,tp)
end
function s.chkfilter(c,tp,...)
	return c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsCode(...)
end
function s.drcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.chkfilter,1,nil,tp,e:GetLabel())
		and not Duel.IsChainSolving()
end
function s.drop1(e,tp,eg,ep,ev,re,r,rp)
	local dam=0
	local g=eg:Filter(s.chkfilter,nil,tp,e:GetLabel())
	for tc in aux.Next(g) do
		local atk,def=tc:HasAttack() and tc:GetAttack() or 0,tc:HasDefense() and tc:GetDefense() or 0
		dam=dam+math.max(atk,def)
	end
	if dam>0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.chkfilter,1,nil,tp,e:GetLabel())
		and Duel.IsChainSolving()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	local n=Duel.GetFlagEffect(tp,id)
	local g=eg:Filter(s.chkfilter,nil,tp,e:GetLabel())
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1,n)
	end
end
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	local n=Duel.GetFlagEffect(tp,id)
	Duel.ResetFlagEffect(tp,id)
	for i=1,n do
		local dam=0
		local g=Duel.Group(Card.HasFlagEffectLabel,0,0xff,0xff,nil,id,n)
		for tc in aux.Next(g) do
			local atk,def=tc:HasAttack() and tc:GetAttack() or 0,tc:HasDefense() and tc:GetDefense() or 0
			dam=dam+math.max(atk,def)
		end
		if dam>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end

--E2
function s.cfilter2(c,e,tp)
	if not (c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST)) then return false end
	local ct=c:GetOverlayGroup():FilterCount(Card.IsCode,nil,CARD_NUMBER_I209_FALLEN_OF_VERDANSE)
	if c==e:GetHandler() then
		local f=mat and Card.IsAbleToRemoveFacedown or Card.IsAbleToDeck
		if ct==0 then
			return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		elseif ct==1 then
			return Duel.IsExistingMatchingCard(aux.OR(Card.IsAbleToDeck,Card.IsAbleToRemoveFacedown),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)
		else
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)
		end
	else
		if ct==0 then
			return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		else
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)
		end
	end
	return true
end
function s.xfilter(c,tp)
	if not Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		return not c:IsCode(CARD_NUMBER_I209_FALLEN_OF_VERDANSE)
	else
		return c:IsCode(CARD_NUMBER_I209_FALLEN_OF_VERDANSE)
	end
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local ct=tc:GetOverlayGroup():FilterCount(Card.IsCode,nil,CARD_NUMBER_I209_FALLEN_OF_VERDANSE)
		if tc==e:GetHandler() and ct==1 and (not Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			or not Duel.IsExistingMatchingCard(Card.IsAbleToRemoveFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)) then
			tc:RemoveCustomOverlayCard(tp,s.xfilter,1,1,e,REASON_COST,tp)
		else
			tc:RemoveOverlayCard(tp,1,1,REASON_COST)
		end
	end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 and e:IsCostChecked() then return true end
	local c=e:GetHandler()
	local mat=c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,CARD_NUMBER_I209_FALLEN_OF_VERDANSE)
	local f=mat and Card.IsAbleToRemoveFacedown or Card.IsAbleToDeck
	if chk==0 then
		return Duel.IsExistingMatchingCard(f,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)
	end
	local g=Duel.GetMatchingGroup(f,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp)
	Duel.SetConditionalOperationInfo(not mat,0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetConditionalOperationInfo(mat,0,CATEGORY_REMOVE,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hint=HINTMSG_TODECK
	local f=Card.IsAbleToDeck
	if c:IsRelateToChain() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,CARD_NUMBER_I209_FALLEN_OF_VERDANSE) then
		hint=HINTMSG_REMOVE
		f=Card.IsAbleToRemoveFacedown
	end
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	if #g>0 then
		Duel.HintSelection(g)
		if hint==HINTMSG_TODECK then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		else
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end