--created & coded by Lyris, art from Shadowverse's "Shion, Immortal Aegis"
--永久の波動拳
local s,id,o=GetID()
function s.initial_effect(c)
	c:RegisterSetCardString("Hadouken")
	c:EnableReviveLimit()
	aux.AddOrigSpatialType(c)
	aux.AddSpatialProc(c,nil,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetDescription(1152)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetDescription(1190)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.spt_other_space=102400027
function s.filter(c,e,tp)
	return c:IsSetCard("Hadouken") and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil),nil,SEQ_DECKBOTTOM,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=9
	if Duel.IsPlayerAffectedByEffect(tp,102400030) then ct=ct*2 end
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=9
	if Duel.IsPlayerAffectedByEffect(tp,102400030) then ct=ct*2 end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return end
	local g=Group.CreateGroup()
	for i=0,ct-1 do g:AddCard(Duel.GetFieldCard(tp,LOCATION_DECK,i)) end
	for p=0,1 do Duel.ConfirmCards(p,g,true) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=g:FilterSelect(tp,Card.IsSetCard,1,1,nil,"Hadouken"):GetFirst()
	if tc then
		Duel.DisableShuffleCheck()
		if tc:IsAbleToHand() then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
			Duel.ShuffleHand(tp)
		else Duel.SendtoGrave(tc,REASON_RULE) end
		g:RemoveCard(tc)
	end
	for i=1,#g do Duel.MoveSequence(Duel.GetFieldCard(tp,LOCATION_DECK,0),SEQ_DECKTOP) end
end
