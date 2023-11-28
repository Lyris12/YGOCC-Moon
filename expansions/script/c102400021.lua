--created & coded by Lyris, art from Shadowverse's Evolved "Norn, Arbiter of Worlds"
--審判の波動拳
local s,id,o=GetID()
function s.initial_effect(c)
	c:RegisterSetCardString("Hadouken")
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(2,id)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard("Hadouken")
end
function s.sfilter(c,e,tp)
	return c:IsSetCard("Hadouken") and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=3
	if Duel.IsPlayerAffectedByEffect(tp,102400030) then ct=ct*2 end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
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
	local mg=g:Filter(s.sfilter,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #mg>0 and Duel.SelectEffectYesNo(tp,c) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=mg:Select(tp,1,1,nil)
		Duel.BreakEffect()
		Duel.DisableShuffleCheck()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
	end
	for i=1,#g do Duel.MoveSequence(Duel.GetFieldCard(tp,LOCATION_DECK,0),SEQ_DECKTOP) end
end
