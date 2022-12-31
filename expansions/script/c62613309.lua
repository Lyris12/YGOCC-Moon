--Waltz, la Nottesfumo Decadenza
--Script by XGlitchy30
function c62613309.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x6233),5,2,c62613309.ovfilter,aux.Stringid(62613309,0),2,c62613309.xyzop)
	c:EnableReviveLimit()
	--send to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62613309,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,62613309)
	e1:SetCost(c62613309.tgcost)
	e1:SetTarget(c62613309.tgtg)
	e1:SetOperation(c62613309.tgop)
	c:RegisterEffect(e1)
end
--filters
function c62613309.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6233) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_SYNCHRO) and c:GetLevel()==5
end
function c62613309.cfilter(c)
	return c:IsSetCard(0x6233) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
--xyz alternative limit
function c62613309.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,62613309)==0 end
	Duel.RegisterFlagEffect(tp,62613309,RESET_PHASE+PHASE_END,0,1)
end
--send to GY
function c62613309.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c62613309.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c62613309.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c62613309.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function c62613309.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end