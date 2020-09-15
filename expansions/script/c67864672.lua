--VECTOR Frame: Drakkhen
--Scripted by Zerry
local function ID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cod=ID()
function cod.initial_effect(c)
--Xyz Material
aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x2a6),4,2)
c:EnableReviveLimit()
--Equip
local e3=Effect.CreateEffect(c)
e3:SetType(EFFECT_TYPE_QUICK_O)
e3:SetCategory(CATEGORY_EQUIP)
e3:SetCode(EVENT_FREE_CHAIN)
e3:SetHintTiming(0,TIMING_END_PHASE)
e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
e3:SetCountLimit(1,67864672+100)
e3:SetRange(LOCATION_MZONE)
e3:SetCost(cod.cost)
e3:SetTarget(cod.target)
e3:SetOperation(cod.operation)
c:RegisterEffect(e3)
--To Hand
local e4=Effect.CreateEffect(c)
e4:SetDescription(aux.Stringid(11000163,0))
e4:SetCategory(CATEGORY_TOHAND)
e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e4:SetCode(EVENT_SPSUMMON_SUCCESS)
e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
e4:SetCountLimit(1,67864672)
e4:SetCondition(cod.thcon)
e4:SetTarget(cod.thtg)
e4:SetOperation(cod.thop)
c:RegisterEffect(e4)
end
function cod.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a6) and c:IsType(TYPE_LINK)
end
function cod.checkzone(tp)
	local zone=0
	local g=Duel.GetMatchingGroup(cod.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		zone=bit.bor(zone,tc:GetLinkedZone(tp))
	end
	return bit.band(zone,0x1f)
end
function cod.thcon(e,tp,eg,ep,ev,re,r,rp)
	return 2^e:GetHandler():GetSequence()&cod.checkzone(tp)~=0
end
function cod.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cod.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function cod.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a6)
end
function cod.filter2(c)
	return c:IsSetCard(0x2a6) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function cod.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and cod.cfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cod.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(cod.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cod.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function cod.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local sg=Duel.SelectMatchingCard(tp,cod.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	local sc=sg:GetFirst()
	if sc then
		if not Duel.Equip(tp,sc,tc) then return end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(cod.eqlimit)
		e1:SetLabelObject(tc)
		sc:RegisterEffect(e1)
	end
end
function cod.eqlimit(e,c)
	return e:GetLabelObject()==c
end
