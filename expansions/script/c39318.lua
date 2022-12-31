function c39318.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39318)
	e1:SetOperation(c39318.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39311,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c39318.tg)
	e2:SetCountLimit(1,39326)
	e2:SetOperation(c39318.op)
	c:RegisterEffect(e2)
end
function c39318.filter1(c)
	return c:GetCode()>39300 and c:GetCode()<39326 and not c:IsCode(39311,39312) and c:IsSummonable(true,nil)
end
function c39318.filter2(c,e,tp)
	return c:GetCode()>39300 and c:GetCode()<39326 and not c:IsCode(39311,39312) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c39318.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g1=Duel.GetMatchingGroup(c39318.filter1,tp,LOCATION_HAND,0,nil)
		local g2=Duel.GetMatchingGroup(c39318.filter2,tp,LOCATION_GRAVE,0,nil,e,tp)
		local ct1=g1:GetCount()
		local ct2=g2:GetCount()
		sel=0
		if ct1>0 then sel=sel+1 end
		if ct2>0 then sel=sel+2 end
		return sel~=0
	end
	if sel==3 then
		e:SetLabel(Duel.SelectOption(tp,aux.Stringid(39318,0),aux.Stringid(39318,1))+1)
	elseif sel==1 then
		e:SetLabel(1)
	elseif sel==2 then
		e:SetLabel(2)
	end
end
function c39318.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local sel=e:GetLabel()
	if sel==0 then return end
	if sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local g=Duel.SelectMatchingCard(tp,c39318.filter1,tp,LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.Summon(tp,tc,true,nil)
		end
	elseif sel==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local g=Duel.SelectMatchingCard(tp,c39318.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function c39318.filter(c)
	return c:IsCode(39311) and c:IsAbleToHand()
end
function c39318.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c39318.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(39318,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
