--Shadowflame Calvalry
--Design and code by Kindrindra
local ref=_G['c'..28915253]
local id=28915253
function ref.initial_effect(c)
    --Destroy
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(ref.destg)
    e1:SetOperation(ref.desop)
    c:RegisterEffect(e1)
    --Special Summon
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(ref.sscon)
    e2:SetTarget(ref.sstg)
    e2:SetOperation(ref.ssop)
    c:RegisterEffect(e2)
end

function ref.desfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function ref.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsOnField() and ref.desfilter(chkc) and not chkc==c end
    if chk==0 then return Duel.IsExistingTarget(ref.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,ref.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,c)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function ref.desop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
    Duel.Destroy(sg,REASON_EFFECT)
    sg=Duel.GetOperatedGroup()
    local d1=0
    local d2=0
    local tc=sg:GetFirst()
    while tc do
        if tc then
            if tc:GetPreviousControler()==0 then d1=d1+1
            else d2=d2+1 end
        end
        tc=sg:GetNext()
    end
    if d1>0 then Duel.Draw(0,d1,REASON_EFFECT) end
    if d2>0 then Duel.Draw(1,d2,REASON_EFFECT) end
end

--Special Summon
function ref.sscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function ref.ssfilter(c,tp)
    return c:IsType(TYPE_TRAP) --and c:IsSetCard(0x729)
        and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),nil,0x11,1700,800,4,RACE_PYRO,ATTRIBUTE_DARK)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(ref.ssfilter,tp,LOCATION_GRAVE,0,1,c,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectTarget(tp,ref.ssfilter,tp,LOCATION_GRAVE,0,1,1,c,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_GRAVE)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
    local tc=Duel.GetFirstTarget()
    if tc then
        tc:SetStatus(STATUS_NO_LEVEL,false)
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(TYPE_NORMAL+TYPE_MONSTER)
        e1:SetReset(RESET_EVENT+0x47c0000)
        tc:RegisterEffect(e1,true)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CHANGE_RACE)
        e2:SetValue(RACE_PYRO)
        tc:RegisterEffect(e2,true)
        local e3=e1:Clone()
        e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e3:SetValue(ATTRIBUTE_DARK)
        tc:RegisterEffect(e3,true)
        local e4=e1:Clone()
        e4:SetCode(EFFECT_SET_BASE_ATTACK)
        e4:SetValue(1700)
        tc:RegisterEffect(e4,true)
        local e5=e1:Clone()
        e5:SetCode(EFFECT_SET_BASE_DEFENSE)
        e5:SetValue(800)
        tc:RegisterEffect(e5,true)
        local e6=e1:Clone()
        e6:SetCode(EFFECT_CHANGE_LEVEL)
        e6:SetValue(4)
        tc:RegisterEffect(e6,true)
        Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
    end
end