--Steinitz’s Angel
--Keddy was here~
local function ID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
--[[Equip only to a "Steinitz" monster. The equipped monster does not have to activate it's effects during the End Phase. A monster equipped to this card gains the following effect.
• You can send 1 other face-up card you control to the GY; add 1 "Steinitz" monster from your Deck to your hand. 
If this card is sent from the field to the GY: You can Special Summon 1 "Steinitz" monster from your hand to the column this card was in while on the field. You can only use this effect of "Steinitz's Angel" once per turn.]]
local id,cod=ID()
function cod.initial_effect(c)
	--Equip
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetTarget(cod.target)
    e1:SetOperation(cod.operation)
    c:RegisterEffect(e1)
    --Equip limit
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(cod.eqlimit)
    c:RegisterEffect(e2)
	--End Phase
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
    e3:SetRange(LOCATION_SZONE)
    c:RegisterEffect(e3)
	--Search
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(cod.thcost)
	e4:SetTarget(cod.thtg)
	e4:SetOperation(cod.thop)
	local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e5:SetRange(LOCATION_SZONE)
    e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e5:SetTarget(function (e,c) return e:GetHandler():GetEquipTarget()==c end)
    e5:SetLabelObject(e4)
    c:RegisterEffect(e5)
	--Special Summon
	local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_LEAVE_FIELD_P)
    e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e6:SetOperation(cod.checkop)
    c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,1))
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e7:SetCode(EVENT_TO_GRAVE)
    e7:SetCountLimit(1,id)
    e7:SetLabelObject(e6)
    e7:SetCondition(cod.spcon)
    e7:SetTarget(cod.sptg)
    e7:SetOperation(cod.spop)
    c:RegisterEffect(e7)
end
function cod.eqlimit(e,c)
    return c:IsSetCard(0x63d0)
end
function cod.filter(c)
    return c:IsFaceup() and c:IsSetCard(0x63d0)
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and cod.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(cod.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,cod.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function cod.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Equip(tp,e:GetHandler(),tc)
    end
end
function cod.tfilter(c)
	return c:IsFaceup()
end
function cod.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.tfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cod.tfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function cod.hfilter(c)
	return c:IsSetCard(0x63d0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cod.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.hfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cod.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cod.hfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cod.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=0
	if c:GetDestination()==LOCATION_GRAVE then
		zone=zone|c:GetColumnZone(LOCATION_MZONE)
		zone=zone|~0x1f
		e:SetLabel(zone)
	else
		e:SetLabel(0)
	end
end
function cod.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function cod.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x63d0) and c:IsType(TYPE_MONSTER) and zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function cod.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetLabelObject():GetLabel()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,LOCATION_REASON_TOFIELD,zone)>0
		and Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cod.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabelObject():GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cod.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end