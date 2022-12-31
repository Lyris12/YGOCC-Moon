--Varia Mage Overlay Witch
function c249000545.initial_effect(c)
	--xyzlv
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c249000545.xyzlv)
	c:RegisterEffect(e1)
	--effect gain
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65192027,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,249000545)
	e2:SetCost(c249000545.cost)
	e2:SetOperation(c249000545.operation)
	c:RegisterEffect(e2)
end
function c249000545.xyzlv(e,c)
	return 0x60000+e:GetHandler():GetLevel()
end
function c249000545.costfilter(c,code)
	return c:IsSetCard(0x1C8) and c:IsAbleToRemoveAsCost() and c:GetCode()~=code
end
function c249000545.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000545.costfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler():GetCode()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249000545.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler():GetCode())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249000545.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		--special summon
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(33420078,0))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCost(c249000545.cost2)
		e1:SetTarget(c249000545.target)
		e1:SetOperation(c249000545.operation2)
		e1:SetReset(RESET_PHASE+PHASE_END+0xfa0000)
		e1:SetLabel(0)
		c:RegisterEffect(e1)
	end
end
function c249000545.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel() < 1 or Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,e:GetLabel(),e:GetHandler()) end
	if e:GetLabel() > 0 then Duel.DiscardHand(tp,Card.IsDiscardable,e:GetLabel(),e:GetLabel(),REASON_COST+REASON_DISCARD) end
end
function c249000545.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c249000545.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		e:SetLabel(e:GetLabel()+1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetOperation(c249000545.resetop)
		e1:SetLabelObject(e)
		Duel.RegisterEffect(e1,tp)
	end
end
function c249000545.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end