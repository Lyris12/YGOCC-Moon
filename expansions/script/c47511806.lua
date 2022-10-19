--Ricercatore Deltaingranaggi
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(aux.CreateCost(aux.SSLimit(s.limfilter,1,true,nil,id,s.counterfilter),aux.ToDeckSelfCost))
	e1:SetTarget(aux.SSTarget(s.spfilter,LOCATION_DECK,0,1))
	e1:SetOperation(aux.SSOperation(s.spfilter,LOCATION_DECK,0,1))
	c:RegisterEffect(e1)
	--look at hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_TOHAND+TIMING_DRAW+TIMING_MAIN_END)
	e2:HOPT()
	e2:SetCondition(aux.MainPhaseCond())
	e2:SetCost(aux.DiscardCost())
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.counterfilter(c)
	return c:IsSetCard(0xfa6) or not c:IsSummonLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.limfilter(c)
	return c:IsSetCard(0xfa6) or not c:IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spfilter(c)
	return c:IsSetCard(0xfa6) and c:IsLevelBelow(6)
end

function s.thfilter(c,tp,g)
	return c:IsSetCard(0xfa6) and c:IsType(TYPE_MONSTER|TYPE_ST)
		and ((not g and Duel.IsPlayerCanSendtoHand(tp,c)) or (g and g:IsExists(Card.IsType,1,nil,c:GetType()&(TYPE_MONSTER|TYPE_ST)) and c:IsAbleToHand()))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #g==0 then return false end
		if g:IsExists(aux.NOT(Card.IsPublic),1,nil) then
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp)
		else
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,nil,g)
		end
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=g:RandomSelect(tp,1)
	if #sg>0 then
		Duel.ConfirmCards(tp,sg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,nil,sg)
		if #tg>0 then
			Duel.BreakEffect()
			Duel.Search(tg,tp)
		end
		Duel.ShuffleHand(1-tp)
	end
end