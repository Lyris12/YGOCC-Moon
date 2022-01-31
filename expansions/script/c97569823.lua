--Balthazar, Prince of the Silent Star
function c97569823.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),5,3)
	--return to deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97569823,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c97569823.tdcon)
	e1:SetTarget(c97569823.tdtg)
	e1:SetOperation(c97569823.tdop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97569823,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c97569823.descon)
	e2:SetCost(c97569823.descost)
	e2:SetTarget(c97569823.destg)
	e2:SetOperation(c97569823.desop)
	c:RegisterEffect(e2)
	local e5=e2:Clone()
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e5:SetCondition(c97569823.con)
	c:RegisterEffect(e5)
end
function c97569823.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,97569840)
end
function c97569823.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_XYZ
end
function c97569823.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL)
end
function c97569823.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(c97569823.tdfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c97569823.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c97569823.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end
function c97569823.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0xd0a1)
end
function c97569823.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c97569823.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd0a2) and c:IsType(TYPE_EQUIP)
end
function c97569823.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c97569823.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0 end
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c97569823.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(c97569823.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE):Select(tp,1,ct,nil)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end