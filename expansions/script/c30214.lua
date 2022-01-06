--Mantra Leech
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:GetCode()>30200 and tc:GetCode()<30230 end)
	--SS Equip
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(scard.eqcon)
	e1:SetTarget(scard.eqtg)
	e1:SetOperation(scard.eqop)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(scard.descost)
	e2:SetTarget(scard.destg)
	e2:SetOperation(scard.desop)
	c:RegisterEffect(e2,true)
end
function scard.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return ((e:GetHandler():IsReason(REASON_EFFECT)) or e:GetHandler():IsReason(REASON_COST))
		and re:IsHasType(0xFFD) and re:GetHandler():IsMantra()
end
function scard.eqfilter(c)
	return c:IsFaceup()
end
function scard.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and scard.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(scard.eqfilter,1-tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,scard.eqfilter,1-tp,LOCATION_MZONE,0,1,1,nil)
end
function scard.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:GetControler()~=1-tp
	or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return false
	end
	Duel.Equip(tp,c,tc,true)
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	e1:SetValue(scard.eqlimit)
	c:RegisterEffect(e1)
end
function scard.eqlimit(e,c)
	return e:GetOwner()==c
end
function scard.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsMantra() and c:IsLocation(LOCATION_HAND) and c:IsAbleToGraveAsCost()
end
function scard.somefilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function scard.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(scard.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,scard.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function scard.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetHandler():GetEquipTarget()
	ec:CreateEffectRelation(e)
	e:SetLabelObject(ec)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,ec,1,0,0)
end
function scard.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ec=e:GetLabelObject()
	if ec:IsRelateToEffect(e) and ec:IsFaceup() then
		Duel.SendtoGrave(ec,REASON_EFFECT)
		Duel.Draw(tp,1,REASON_EFFECT) end
end
