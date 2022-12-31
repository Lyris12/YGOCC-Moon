function c210216015.initial_effect(c)
	c:EnableReviveLimit()
	--cannot disable effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_DISABLE)
	c:RegisterEffect(e1)
	--spsummon limit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(c210216015.splimit)
	c:RegisterEffect(e5)
		--Exile effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetDescription(aux.Stringid(77334267,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c210216015.descost)
	e3:SetTarget(c210216015.destg)
	e3:SetOperation(c210216015.desop)
	c:RegisterEffect(e3)
end
function c210216015.splimit(e,se,sp,st)
	return (se:GetHandler():IsSetCard(0x216) and se:GetHandler():IsType(TYPE_TRAP)) or e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c210216015.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c210216015.filter(c)
	return c:IsFacedown() or not c:IsFacedown()
end
function c210216015.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c210216015.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210216015.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c210216015.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c210216015.desop(e,tp,eg,ep,ev,re,r,rp)
       local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
    Duel.Exile(tc,REASON_RULE+REASON_EFFECT)
	end
end