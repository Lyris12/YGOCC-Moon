--Burnetic Hero
  local cid,id=GetID()
function cid.initial_effect(c)
   aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,8,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),2)  
   --destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(cid.descost)
	e1:SetTarget(cid.destg)
	e1:SetOperation(cid.desop)
	c:RegisterEffect(e1)
  
 --damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
end

function cid.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(cid.desfilterxx,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function cid.desfilterxx(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
function cid.descost(e,tp,eg,ep,ev,re,r,rp,chk)
   local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,4,REASON_COST) and Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:GetHandler():RemoveEC(tp,4,REASON_COST)
	c:RegisterFlagEffect(id,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_PZONE) and cid.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,cid.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_ONFIELD)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,cid.desfilterxx,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			Duel.HintSelection(g)
			Duel.SendtoGrave(g,nil,REASON_EFFECT)
		end
	end
end


function cid.filter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsReason(REASON_EFFECT)
end

function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local d1=eg:FilterCount(cid.filter,nil,tp)*200
	Duel.Damage(1-tp,d1,REASON_EFFECT,true)
	Duel.RDComplete()
end
