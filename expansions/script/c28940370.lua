--Converguard Shepherd
local ref,id=GetID()
Duel.LoadScript("Commons_Converguard.lua")
function ref.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,2,Converguard.TimeleapCon(c:GetOriginalAttribute()),{ref.tlfilter,true})
	c:EnableReviveLimit()
	--On-Summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.TimeleapSummonedCond,nil,ref.thtg,ref.thop)
	c:RegisterEffect(e1)
	--Float
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(ref.tdtg)
	e2:SetOperation(ref.tdop)
	c:RegisterEffect(e2)
end
function ref.tlfilter(c,e,mg)
	return Converguard.TimeleapMat(c,e,mg) and (c:IsLevel(e:GetHandler():GetFuture()-1) or not c:IsOnField())
end

--On-Summon
function ref.thfilter(c,e,tp)
	return Converguard.Is(c) and c:IsAbleToHand()
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then Duel.ConfirmCards(1-tp,g) end
end

--Float
function ref.tdfilter(c,e,arch)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e) and (Converguard.Is(c) or not arch)
end
function ref.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(ref.tdfilter,tp,LOCATION_REMOVED,0,1,nil,e,true)
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,ref.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,true)
	local g2=Duel.SelectMatchingCard(tp,ref.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,false)
	g1:Merge(g2)
	Duel.SetTargetCard(g1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,#g1,0,0)
end
function ref.tdop(e,tp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then Duel.SendtoDeck(g,nil,2,REASON_EFFECT) end
end
