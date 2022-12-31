--Knight of White Belief
--scripted by Rawstone
local s,id=GetID()
function s.initial_effect(c)
		--special summon
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(502235,0))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_HAND)
		e1:SetCountLimit(1,id)
		e1:SetTarget(s.sptg)
		e1:SetOperation(s.spop)
		c:RegisterEffect(e1)
		--send light
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_TOGRAVE)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_REMOVE)
		e2:SetProperty(EFFECT_FLAG_DELAY)
		e2:SetCountLimit(1,id+500)
		e2:SetCondition(s.condition)
		e2:SetTarget(s.target)
		e2:SetOperation(s.operation)
		c:RegisterEffect(e2)
end
	function s.spfilter(c)
	return (c:IsCode(502233) or c:IsCode(49306994)) and not c:IsPublic()
end
	function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,c)
	local tc=g:GetFirst()
	Duel.ConfirmCards(1-tp,g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
	function s.filta(c)
	return c:IsType(TYPE_EQUIP)
end
	function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=1
		and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(s.filta,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(502235,0)) then
			local g=Duel.SelectMatchingCard(tp,s.filta,tp,LOCATION_HAND,0,1,1,nil)
			local tc=g:GetFirst()
				if tc and Duel.SendtoDeck(tc,nil,1,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end 
end
	function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(TYPE_FUSION)
end
	function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGrave()
end
	function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
	function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
