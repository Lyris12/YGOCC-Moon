--Gypssy of the Shisune, Jiuwei
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    c:EnableReviveLimit()
	--Must be Ritual Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
    c:RegisterEffect(e1)
    --Reduce ATK/DEF
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_DECK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(cid.condition)
    e2:SetOperation(cid.operation)
    c:RegisterEffect(e2)
    --Reduce and recover
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
	e3:SetTarget(cid.tdtg)
	e3:SetOperation(cid.tdop)
    c:RegisterEffect(e3)
end

--Ritual Summon without using a card with the same name

function cid.mat_filter(c)
	return not c:IsCode(id)
end

--Reduce ATK/DEF

function cid.filter(c, tp)
    return c:IsSetCard(0x570) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_GRAVE)
end
function cid.condition(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(cid.filter, 1, nil, tp)
end
function cid.operation(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    local tc=mg:GetFirst()
    while tc do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-300)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(e2)
        tc=mg:GetNext()
    end
end

--Reduce and recover

function cid.tdfilter(c)
    return c:IsSetCard(0x570) and c:IsAbleToDeck()
end
function cid.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_ONFIELD+LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 1000)
end
function cid.tdop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, cid.tdfilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, 1, nil)
    if g:GetCount()==0 then return end
    if Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        if g:GetFirst():IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
        Duel.SetLP(1-tp, Duel.GetLP(1-tp)-1000)
        Duel.BreakEffect()
        Duel.Recover(tp, 1000, REASON_EFFECT)
    end
end
