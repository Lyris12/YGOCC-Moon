--Numbing Winter Jewel
function c79854546.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c79854546.target)
	e1:SetOperation(c79854546.operation)
	c:RegisterEffect(e1)
	--equiplimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c79854546.eqlimit)
	c:RegisterEffect(e2)
	--protect the rest
	local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_ONFIELD,0)
    e3:SetCondition(c79854546.descon)
    e3:SetTarget(c79854546.infilter)
    e3:SetValue(1)
	c:RegisterEffect(e3)
	--justdestroyinstead
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(79854546,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c79854546.chcon)
	e4:SetTarget(c79854546.chtg)
	e4:SetOperation(c79854546.chop)
	c:RegisterEffect(e4)
	--destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetTarget(c79854546.reptg)
	c:RegisterEffect(e5)
end
--Activate
function c79854546.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
function c79854546.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c79854546.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c79854546.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c79854546.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c79854546.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end
--equiplimit
function c79854546.eqlimit(e,c)
	return c:IsRace(RACE_PLANT)
end
--protect the rest
function c79854546.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetEquipTarget() and e:GetHandler():GetEquipTarget():IsType(TYPE_SYNCHRO)
end
function c79854546.infilter(e,c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(79854546)
end
--justdestroyinstead
function c79854546.chcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return (re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE)
		or ((re:GetActiveType()==TYPE_SPELL or re:GetActiveType()==TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function c79854546.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c79854546.desfilter,rp,0,LOCATION_ONFIELD,1,nil) end
end
function c79854546.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,c79854546.repop)
end
function c79854546.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c79854546.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetType()==TYPE_SPELL or c:GetType()==TYPE_TRAP then
		c:CancelToGrave(false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c79854546.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--justdontdestroyinstead
function c79854546.repfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemove()
end
function c79854546.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(c79854546.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,c79854546.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
