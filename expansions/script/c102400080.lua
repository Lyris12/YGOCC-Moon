--created & coded by Lyris, art from Magic the Gathering's "Seraph of Dawn"
--天剣主翔
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,0x1c0)
	e0:SetTarget(s.target1)
	e0:SetOperation(s.operation1)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsDefensePos))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetDescription(1104)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.tg)
	e3:SetValue(function(e,re,rp) return rp~=e:GetHandlerPlayer() end)
	c:RegisterEffect(e3)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0xbb2)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	local ct=Duel.GetCurrentChain()
	if ct==1 then return end
	local pe=Duel.GetChainInfo(ct-1,CHAININFO_TRIGGERING_EFFECT)
	if not pe:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not pe:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP) or not pe:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local tg=Duel.GetChainInfo(ct-1,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsExists(s.cfilter,1,nil) then return end
	if not Duel.IsChainNegatable(ct-1) then return end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),94) then
		e:SetLabel(1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xbb2) and c:IsAbleToHand()
end
function s.sfilter(c,e,tp,code)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code)
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()~=1 then return end
	if not c:IsRelateToEffect(e) then return end
	local ct=Duel.GetChainInfo(0,CHAININFO_CHAIN_COUNT)
	local tg=Duel.GetChainInfo(ct-1,CHAININFO_TARGET_CARDS)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=tg:FilterSelect(tp,s.filter,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetCode()),0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not re:GetHandler():IsType(TYPE_TRAP) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsExists(s.cfilter,1,nil) then return false end
	return Duel.IsChainNegatable(ev)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if eg:GetFirst():IsDestructable() then
		eg:GetFirst():CreateEffectRelation(e)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=tg:FilterSelect(tp,s.filter,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetCode()),0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tg(e,c)
	return c:IsFaceup() and c:IsSetCard(0xbb2)
end
