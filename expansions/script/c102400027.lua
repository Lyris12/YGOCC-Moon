--created & coded by Lyris, art from Shadowverse's Evolved "Shion, Immortal Aegis"
--Undying Hadoken (Altered)
local s,id,o=GetID()
if not s.global_check then
	s.global_check=true
	local f=Card.IsHadoken
	function Card.IsHadoken(c) return f and f(c) or c:IsCode(id) end
end
function s.initial_effect(c)
	c:EnableReviveLimit(c)
	aux.AddOrigSpatialType()
	aux.AddSpatialProc(c,nil,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetTarget(s.xptg)
	e2:SetOperation(s.xpop)
	c:RegisterEffect(e2)
end
s.spt_other_space=102400025
function s.filter(c,e,tp)
	return c:IsHadoken() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.dfilter(c)
	return c:IsAbleToDeck() and not c:IsCode(s.spt_other_space)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local sg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,g)
		if #sg==0 then return end
		Duel.BreakEffect()
		Duel.SendtoDeck(sg:Select(tp,1,1,nil),nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
function s.sfilter(c,e,tp)
	return c:IsHadoken() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>5
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function s.xpop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<6 then return end
	local g=Group.CreateGroup()
	for i=1,6 do g:AddCard(Duel.GetFieldCard(tp,LOCATION_DECK,i)) end
	for p=0,1 do Duel.ConfirmCards(p,g) end
	local mg=g:Filter(s.sfilter,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #mg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=mg:Select(tp,1,1,nil)
		Duel.DisableShuffleCheck()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
	end
	for i=1,#g do Duel.MoveSequence(Duel.GetFieldCard(tp,LOCATION_DECK,SEQ_DECKBOTTOM),SEQ_DECKTOP) end
end
