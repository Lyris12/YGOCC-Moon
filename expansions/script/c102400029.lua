--created & coded by Lyris, art from Shadowverse's "Arc"
--Hadoken Ark Box
local s,id,o=GetID()
if not s.global_check then
	s.global_check=true
	local f=Card.IsHadoken
	function Card.IsHadoken(c) return f and f(c) or c:IsCode(id) end
end
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function s.filter(c,e,tp)
	return c:IsHadoken() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cfilter(c)
	return c:IsHadoken() and not c:IsCode(id)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local g=Group.CreateGroup()
	for i=1,3 do
		local tc=Duel.GetFieldCard(tp,LOCATION_DECK,i)
		Duel.ConfirmCards(1-tp,tc)
		g:AddCard(tc)
	end
	local mg=g:Filter(s.filter,1,nil,e,tp)
	local chk=g:IsExists(s.cfilter,1,nil)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #mg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=mg:Select(tp,1,1,nil)
		Duel.DisableShuffleCheck()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
	end
	for i=1,#g do Duel.MoveSequence(Duel.GetFieldCard(tp,LOCATION_DECK,SEQ_DECKBOTTOM),SEQ_DECKTOP) end
	if chk then Duel.SortDecktop(tp,tp,#g) end
end
