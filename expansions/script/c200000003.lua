--Naval Gears - Z18
local cid,id=GetID()
function cid.initial_effect(c)
--if grave by not battle: search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83239739,0))
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.condition)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
	--if set in back row: move other card to back row
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_MOVE)
    e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,id+1000)
	e5:SetCondition(cid.tfcon)
	e5:SetOperation(cid.desop)
	c:RegisterEffect(e5)
end
--if set in back row: move other card to back row
function cid.tfcon(e,tp,eg,ep,ev,re,r,rp)
return eg:IsExists(cid.condfilter,1,nil,e:GetHandler())
end
function cid.condfilter(c,card)
    return c==card and c:IsLocation(LOCATION_SZONE) and not c:IsPreviousLocation(LOCATION_SZONE)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
if not e:GetHandler():IsRelateToEffect(e) then return end
local g=Duel.SelectMatchingCard(tp,aux.FilterBoolFunction(aux.NOT(Card.IsImmuneToEffect),e),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
local tc=g:GetFirst()
if g:GetCount()>0 then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetCode(EFFECT_CHANGE_TYPE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+0x1fc0000)
    e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
    tc:RegisterEffect(e1)
    if tc:IsControler(tp) then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) 
    else Duel.MoveToField(tc,1-tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
end
--if grave by not battle: search
function cid.searchfilter(c)
	return c:IsSetCard(0x700) and not c:IsCode(id) and c:IsAbleToHand()
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
    return not (bit.band(r,REASON_BATTLE+REASON_DESTROY)==REASON_BATTLE+REASON_DESTROY)  
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.searchfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.searchfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
end