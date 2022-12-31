--Dark Luster Soldier of the Black Lotus
--Script by TaxingCorn117
function c27796621.initial_effect(c)
    c:SetUniqueOnField(1,0,27796621)
    c:EnableReviveLimit()
    --splimit
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e0)
    --spsummon proc
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_DECK)
    e1:SetCountLimit(1,27796621)
    e1:SetCondition(c27796621.spcon)
    e1:SetOperation(c27796621.spop)
    c:RegisterEffect(e1)
    --banish/gain lp
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(27796621,0))
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,20796621)
    e2:SetCost(c27796621.lpcost)
    e2:SetTarget(c27796621.lptg)
    e2:SetOperation(c27796621.lpop)
    c:RegisterEffect(e2)
    --draw
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(27796621,1))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,21796621)
    e3:SetCondition(c27796621.drcon)
    e3:SetTarget(c27796621.drtg)
    e3:SetOperation(c27796621.drop)
    c:RegisterEffect(e3)
end
--filters
function c27796621.spfilter(c)
    return c:IsSetCard(0x42d) and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,27796627)
end
function c27796621.filter(c)
    return c:IsFaceup()
end
--spsummon proc
function c27796621.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
        and Duel.CheckReleaseGroup(tp,c27796621.spfilter,1,nil)
end
function c27796621.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectReleaseGroup(tp,c27796621.spfilter,1,1,nil)
    Duel.Release(g,REASON_COST)
    Duel.ShuffleDeck(tp)
end
--banish
function c27796621.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c27796621.filter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
    local g=Duel.GetMatchingGroup(c27796621.filter,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,1,0,0)
    if g:GetCount()>0 then
        local tg=g:GetMaxGroup(Card.GetAttack)
        if tg:GetCount()>1 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=tg:Select(tp,1,1,nil)
            Duel.Remove(sg,POS_FACEDOWN,REASON_COST)
        else Duel.Remove(tg,POS_FACEDOWN,REASON_COST) end
    end
end
function c27796621.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1000)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function c27796621.lpop(e,tp,eg,ep,ev,re,r,rp,chk)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Recover(p,d,REASON_EFFECT)
end
--draw
function c27796621.drcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c27796621.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c27796621.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end