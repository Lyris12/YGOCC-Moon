function c39307.initial_effect(c)
	aux.AddFusionProcCode2(c,39301,39306,true,false)
	c:EnableReviveLimit()
	--Remove
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c39307.rmtg)
	e3:SetOperation(c39307.rmop)
	e3:SetCountLimit(1)
	c:RegisterEffect(e3)
end
function c39307.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDestructable()
end
function c39307.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and c39307.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c39307.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c39307.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c39307.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
