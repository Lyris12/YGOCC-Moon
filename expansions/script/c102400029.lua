--created & coded by Lyris, art from Shadowverse's "Arc"
--波動拳アークボックス
local s,id,o=GetID()
function s.initial_effect(c)
	c:RegisterSetCardString("Hadouken")
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=3
	if Duel.IsPlayerAffectedByEffect(tp,102400030) then ct=ct*2 end
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function s.filter(c)
	return c:IsSetCard("Hadouken") and not c:IsCode(id)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=3
	if Duel.IsPlayerAffectedByEffect(tp,102400030) then ct=ct*2 end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return end
	local g=Group.CreateGroup()
	for i=0,ct-1 do
		local tc=Duel.GetFieldCard(tp,LOCATION_DECK,i)
		if ct<6 then for p=0,1 do Duel.ConfirmCards(p,tc,true) end end
		g:AddCard(tc)
	end
	if ct>5 then for p=0,1 do Duel.ConfirmCards(p,g,true) end end
	local mg=g:Filter(s.filter,nil,e,tp)
	local chk=false
	if #mg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=mg:Select(tp,1,1,nil):GetFirst()
		Duel.DisableShuffleCheck()
		if sc:IsAbleToHand() then
			chk=sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND)
			Duel.ConfirmCards(1-tp,sc)
			Duel.ShuffleHand(tp)
		else Duel.SendtoGrave(sc,REASON_RULE) end
		g:RemoveCard(sc)
	end
	for i=1,#g do Duel.MoveSequence(Duel.GetFieldCard(tp,LOCATION_DECK,0),SEQ_DECKTOP) end
	if chk then Duel.SortDecktop(tp,tp,#g) end
end
