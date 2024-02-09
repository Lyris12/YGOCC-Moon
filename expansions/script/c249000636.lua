--Space Time Rift
function c249000636.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c249000636.target)
	e1:SetOperation(c249000636.activate)
	c:RegisterEffect(e1)
end
function c249000636.cfilter(c)
	return c:IsFaceup() and c:IsCode(249000634)
end
function c249000636.spfilter(c,e,tp)
	return c:IsCode(249000634) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c249000636.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000636.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()))
		or (Duel.CheckReleaseGroup(tp,nil,1,nil) and Duel.IsExistingMatchingCard(c249000636.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)) end
	local option
	if Duel.CheckReleaseGroup(tp,nil,1,nil) and Duel.IsExistingMatchingCard(c249000636.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) then option=0 end
	if (Duel.IsExistingMatchingCard(c249000636.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())) then option=1 end
	if Duel.CheckReleaseGroup(tp,nil,1,nil) and Duel.IsExistingMatchingCard(c249000636.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(c249000636.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) then
		option=Duel.SelectOption(tp,500,503)
	end
	if option==0 then
		e:SetLabel(0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,e:GetHandler())
		e:SetLabel(1)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
function c249000636.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local g=Duel.SelectMatchingCard(tp,c249000636.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
		if g:GetCount() < 1 or not Duel.CheckReleaseGroup(tp,nil,1,nil) then return end
		local rg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
		Duel.Release(rg,REASON_EFFECT)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	    local sg=g:Filter(Card.IsRelateToEffect,nil,e)
		if sg:GetCount() > 0 then
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end