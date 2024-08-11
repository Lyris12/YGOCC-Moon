--[[
Schemhamparae "Shahar", Ængelic Dawn
Schemhamparae "Shahar", Alba Ængelica
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigTimeleapType(c)
	--You have 8+ face-down banished cards  - "Ængelic" monster
	aux.AddTimeleapProc(c,11,s.TLcon,aux.FilterBoolFunction(Card.IsSetCard,ARCHE_AENGELIC),aux.TimeleapMaterialBanishFacedown(),s.TLcheck)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(Card.IsSetCard,ARCHE_AENGELIC))
	--[[If this card is Time Leap Summoned: You can add 1 of your face-down banished cards to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetFunctions(aux.TimeleapSummonedCond,nil,s.thtg,s.thop)
	c:RegisterEffect(e1)
	--[[If a card(s) is banished face-down, except by the effect of "Schemhamparae "Shahar", Ængelic Dawn" (except during the Damage Step): You can target 1 card on the field; banish it face-down.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e2:SetFunctions(
		s.rmcon,
		nil,
		s.rmtg,
		s.rmop
	)
	c:RegisterEffect(e2)
	--[[If your opponent Special Summons a monster(s) from the Extra Deck (except during the Damage Step): You can banish 1 card from your hand or GY, face-down;
	Special Summon 1 Level 9 or lower "Ængelic" monster from your Deck.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,3)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e3:SetFunctions(
		s.spcon,
		aux.BanishCost(nil,LOCATION_HAND|LOCATION_GRAVE,0,1,1,false,POS_FACEDOWN),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e3)
end
function s.TLcon(e,tl,tp)
	return Duel.IsExists(false,Card.IsFacedown,tp,LOCATION_REMOVED,0,8,nil)
end
function s.TLcheck(e,tp,eg,ep,ev,re,r,rp,c,g,chk)
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_OATH|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(ARCHE_AENGELIC)
end

--E1
function s.thfilter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

--E2
function s.cfilter(c)
	return c:IsFacedown() and (not c:IsReason(REASON_EFFECT) or not c:GetReasonEffect():GetOwner():IsOriginalCodeRule(id))
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local h=e:GetHandler()
	return not eg:IsContains(h) and eg:IsExists(aux.AlreadyInRangeFilter(e,s.cfilter),1,nil)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove(tp,POS_FACEDOWN) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp,POS_FACEDOWN) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp,POS_FACEDOWN)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end

--E3
function s.spcfilter(c,p)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(p)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local h=e:GetHandler()
	return not eg:IsContains(h) and eg:IsExists(aux.AlreadyInRangeFilter(e,s.spcfilter),1,nil,1-tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_AENGELIC) and c:HasLevel() and c:IsLevelBelow(9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end