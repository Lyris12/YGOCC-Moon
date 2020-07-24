--created by Meedogh, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.FilterEqualFunction(Card.GetVibe,1),1,aux.FilterEqualFunction(Card.GetVibe,-1),1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetDescription(1068)
	e1:SetTarget(cid.eqtg)
	e1:SetOperation(cid.eqop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetDescription(1104)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.op)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+2)
	e3:SetTarget(cid.reptg)
	e3:SetOperation(cid.repop)
	c:RegisterEffect(e3)
end
function cid.eqfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function cid.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cid.eqfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND)
end
function cid.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,cid.eqfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		if not Duel.Equip(tp,tc,c) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(cid.eqlimit)
		tc:RegisterEffect(e1)
	end
end
function cid.eqlimit(e,c)
	return e:GetOwner()==c
end
function cid.cfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER~=0 and c:IsDestructable()
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetEquipGroup():Filter(cid.cfilter,nil)
	if chk==0 then return #g>0 and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.Destroy(g:Select(tp,1,1,nil),REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil),1,0,0)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
function cid.desfilter(c,e)
	return c:IsLocation(LOCATION_SZONE)
		and e:GetHandler():GetEquipGroup():IsContains(c)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function cid.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(cid.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,cid.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
function cid.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
