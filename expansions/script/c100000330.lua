--[[
Retrius, The Roused Ruins
Retrius, Le Rovine Ridestate
Card Author: Kinny
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Level 3 monsters, except monsters whose original Type is Rock
	aux.AddXyzProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsOriginalRace,RACE_ROCK)),3,2)
	--[[You can detach 1 material from this card; until your next Standby Phase, this card cannot be targeted or destroyed by card effects.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		aux.DetachSelfCost(),
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, and you have activated "All Falls To Ruins" this Duel: You can discard 1 "All Falls To Ruins"; Special Summon this card,
	then you can attach 1 card your opponent controls to this card as material.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCustomCategory(CATEGORY_ATTACH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		s.spcon,
		aux.DiscardCost(aux.FilterBoolFunction(Card.IsCode,id-1)),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.PlayerHasFlagEffect(rp,id) and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local code1,code2=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
		if code1==id-1 or code2==id-1 then
			Duel.RegisterFlagEffect(rp,id,0,0,0)
		end
	end
end

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return not e:GetHandler():HasFlagEffect(id)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local rct=Duel.GetNextPhaseCount(PHASE_STANDBY,tp)
		local e1=c:CannotBeDestroyedByEffects(nil,nil,{RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,rct},c,LOCATION_MZONE)
		local e2=c:CannotBeTargetedByEffects(nil,nil,{RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,rct},c,LOCATION_MZONE)
		if not c:IsImmuneToEffect(e1) or not c:IsImmuneToEffect(e2) then
			c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,EFFECT_FLAG_CLIENT_HINT,rct,0,aux.Stringid(id,1))
		end
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.PlayerHasFlagEffect(tp,id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	local g=Duel.Group(Card.IsCanBeAttachedTo,tp,0,LOCATION_ONFIELD,nil,c,e,tp,REASON_EFFECT)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_ATTACH,g,1,1-tp,LOCATION_ONFIELD,c)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsType(TYPE_XYZ) then
		local g=Duel.Group(Card.IsCanBeAttachedTo,tp,0,LOCATION_ONFIELD,nil,c,e,tp,REASON_EFFECT)
		if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_ATTACH) then
			Duel.HintMessage(tp,HINTMSG_ATTACH)
			local sg=g:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.Attach(sg,c,false,e,REASON_EFFECT,tp)
		end
	end
end