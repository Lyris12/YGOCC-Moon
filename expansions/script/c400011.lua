--Untergang Wasserlauf
function c400011.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c400011.target)
	e1:SetOperation(c400011.activate)
	e1:SetCondition(c400011.condition)
	e1:SetCountLimit(1,400011)
	c:RegisterEffect(e1)
end
function c400011.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c400011.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x246)
end
function c400011.dfilter(c,self)
return c:IsSetCard(0x246) and c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_QUICKPLAY) and not c:IsCode(40011)
end
function c400011.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c400011.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c400011.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c400011.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(c400011.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c400011.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c400011.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT) 
    if Duel.IsPlayerCanDraw(tp,1) 
            and Duel.IsExistingMatchingCard(c400011.dfilter,tp,LOCATION_GRAVE,0,1,nil,self) 
            and Duel.SelectYesNo(tp,aux.Stringid(63166095,0)) then
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end
