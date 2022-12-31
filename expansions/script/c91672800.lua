--Percival, Paladawn Light
function c91672800.initial_effect(c)
    c:SetSPSummonOnce(91672800)
    --link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,c91672800.matfilter,1,1)
    --set
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(91672800,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(c91672800.setcon)
    e1:SetTarget(c91672800.settg)
    e1:SetOperation(c91672800.setop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
	local e4=e1:Clone()
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(c91672800.setcon1)
    c:RegisterEffect(e4)
end
function c91672800.matfilter(c)
    return c:IsLinkSetCard(0xbb8) and c:IsLinkType(TYPE_MONSTER) and not c:IsLinkCode(91672800)
end
function c91672800.cfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_NORMAL)
end
function c91672800.cfilter1(c,tp)
    return c:IsType(TYPE_NORMAL) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
        and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function c91672800.cfilter2(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0xbb8)
end
function c91672800.setcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c91672800.cfilter,1,nil,tp)
end
function c91672800.setcon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(c91672800.cfilter1,1,nil,tp)
end
function c91672800.filter1(c)
    return c:IsSetCard(0xbb8) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c91672800.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(c91672800.filter1,tp,LOCATION_DECK,0,1,nil) end
end
function c91672800.setop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if ft<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,c91672800.filter1,tp,LOCATION_DECK,0,1,1,nil)
    local sg=Duel.GetMatchingGroup(c91672800.filter1,tp,LOCATION_DECK,0,nil)
    if Duel.IsExistingMatchingCard(c91672800.cfilter2,tp,LOCATION_MZONE,0,1,nil) and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(91672800,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        g:AddCard(sg:Select(tp,1,1,nil):GetFirst())
    end
    if g:GetCount()>0 then
        Duel.SSet(tp,g)
        Duel.ConfirmCards(1-tp,g)
    end
end

