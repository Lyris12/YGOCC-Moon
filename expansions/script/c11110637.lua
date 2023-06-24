--Oscurion Energy Core
--Nucleo Energetico Oscurione
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Target 1 "Oscurion Type-0 ‹Cradle of the Universe›" you control; it cannot be targeted, or destroyed, by your opponent's card effects, until the end of the next turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, and you control no "Oscurion" Time Leap Monsters: You can reduce the Energy of your Engaged "Oscurion" monster to 1,
	and if you do, shuffle this card into your Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
--FILTERS E1
function s.filter(c)
	return c:IsFaceup() and c:IsCode(CARD_OSCURION_TYPE0) and not c:HasFlagEffect(id)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_ONFIELD,0,1,nil)
	end
	Duel.Select(HINTMSG_FACEUP,true,tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and not tc:HasFlagEffect(id) then
		local c=e:GetHandler()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,2)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_CANNOT_BE_DESTROYED_BY_OPPONENT_EFFECT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(aux.indoval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,2)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(STRING_CANNOT_BE_TARGETED_BY_OPPONENT_EFFECT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetValue(aux.tgoval)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,2)
		tc:RegisterEffect(e2)
	end
end

--FILTERS E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_OSCURION)
end
--E2
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local ec=Duel.GetEngagedCard(tp)
		return ec and ec:IsMonster(TYPE_DRIVE) and ec:IsSetCard(ARCHE_OSCURION) and ec:IsCanChangeEnergy(1,tp,REASON_EFFECT,e) and c:IsAbleToDeck()
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=Duel.GetEngagedCard(tp)
	if ec and ec:IsMonster(TYPE_DRIVE) and ec:IsSetCard(ARCHE_OSCURION) and ec:IsCanChangeEnergy(1,tp,REASON_EFFECT,e) then
		local e,new_en=ec:ChangeEnergy(1,tp,REASON_EFFECT,true,c)
		if new_en==1 and not ec:IsImmuneToEffect(e) and c:IsRelateToChain() then
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end