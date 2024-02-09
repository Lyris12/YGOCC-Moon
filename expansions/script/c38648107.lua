--Portatore di Pioggia Elyriano
--Script by XGlitchy30
function c38648107.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,38648107)
	e1:SetCost(c38648107.cost)
	e1:SetTarget(c38648107.target)
	e1:SetOperation(c38648107.operation)
	c:RegisterEffect(e1)
end
--filters
function c38648107.cfilter(c,ft,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
function c38648107.filter(c,e,tp,code)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetCode()~=code
end
--spsummon
function c38648107.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c38648107.cfilter,1,nil,ft,tp) end
	local g=Duel.SelectReleaseGroup(tp,c38648107.cfilter,1,1,nil,ft,tp)
	Duel.Release(g,REASON_COST)
	local op=Duel.GetOperatedGroup():GetFirst()
	e:SetLabel(op:GetCode())
end
function c38648107.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c38648107.filter(chkc,e,tp,e:GetLabel()) end
	if chk==0 then return Duel.IsExistingTarget(c38648107.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetLabel()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(c38648107.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c38648107.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end