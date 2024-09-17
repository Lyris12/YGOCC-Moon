--Autonomiscient, the Table of Time
local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--[PANDEMONIUM] This card cannot be targeted or destroyed by card effects while you have 2 cards in the Pendulum Zones with the same name.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(1)
	e1:SetCondition(s.indcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--[PANDEMONIUM] Once per trun: You can declare 1 card name; until the end of this turn, the names of all other face-up Spells/Traps you control become that name (even if this card leaves the field).
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(aux.PandActCheck)
	e3:SetTarget(s.nametg)
	e3:SetOperation(s.nameop)
	c:RegisterEffect(e3)
	aux.EnablePandemoniumAttribute(c,e3)
	--If this card is Special Summoned: You can target 1 face-up Spell/Trap on the field; banish it, and if you do, return all other cards on the field with the same name as that target to the hand.
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,{id,0})
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
	--If this card is destroyed as material: You can target 1 face-up card on the field; add 1 card from your Deck to your hand with the same original name as that target.
	 local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.descon)
    e5:SetTarget(s.destg)
    e5:SetOperation(s.desop)
    c:RegisterEffect(e5)
end
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandler():GetControler()
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not tc1 or not tc2 then return false end
	return aux.PandActCheck(e) and tc1:GetCode()==tc2:GetCode()
end

function s.nametg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
    local ac=Duel.AnnounceCard(tp)
    Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD)
end
function s.namefilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.nameop(e,tp,eg,ep,ev,re,r,rp)
    local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.namefilter,tp,LOCATION_ONFIELD,0,c)
    local tc=g:GetFirst()
    while tc do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(ac)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        tc=g:GetNext()
    end
end
function s.thfilter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove() and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c:GetCode())
end
function s.thfilter2(c,code)
	return c:IsFaceup() and c:IsAbleToHand() and c:IsCode(code)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.thfilter1(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.thfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	local tg=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,g:GetFirst(),g:GetFirst():GetCode())
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,#tg,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
	local code=tc:GetCode()
    if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
        local g=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,tc,code)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
        end
    end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetReason(),REASON_MATERIAL)~=0
end
function s.thfilter3(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,c:GetOriginalCode())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.thfilter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tc:GetOriginalCode())
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end
function s.filter(c,code)
    return c:IsCode(code) and c:IsAbleToHand()
end