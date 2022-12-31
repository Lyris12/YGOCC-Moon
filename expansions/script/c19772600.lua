--La Grande Fromboliera degli AoJ, Regaliae Minimae
--Script by XGlitchy30
function c19772600.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddFusionProcCodeFun(c,19772599,aux.FilterBoolFunction(Card.IsFusionSetCard,0x197),2,true,true)
    aux.EnablePendulumAttribute(c,false)
    --PENDULUM EFFECTS
    --scale
    local e1p=Effect.CreateEffect(c)
    e1p:SetType(EFFECT_TYPE_SINGLE)
    e1p:SetCode(EFFECT_CHANGE_LSCALE)
    e1p:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1p:SetRange(LOCATION_PZONE)
    e1p:SetCondition(c19772600.slcon)
    e1p:SetValue(3)
    c:RegisterEffect(e1p)
    local e2p=e1p:Clone()
    e2p:SetCode(EFFECT_CHANGE_RSCALE)
    c:RegisterEffect(e2p)
    --banish
    local e3p=Effect.CreateEffect(c)
    e3p:SetDescription(aux.Stringid(19772600,0))
    e3p:SetType(EFFECT_TYPE_IGNITION)
    e3p:SetRange(LOCATION_PZONE)
    e3p:SetCountLimit(1,19772600)
    e3p:SetCondition(c19772600.rmcon)
    e3p:SetCost(c19772600.rmcost)
    e3p:SetTarget(c19772600.rmtg)
    e3p:SetOperation(c19772600.rmop)
    c:RegisterEffect(e3p)
    --MONSTER EFFECTS
    --spsummon condition
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(c19772600.splimit)
    c:RegisterEffect(e1)
    --special summon rule
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_EXTRA)
    e2:SetCondition(c19772600.spcon)
    e2:SetOperation(c19772600.spop)
    e2:SetValue(50331648)
    c:RegisterEffect(e2)
    --spsummon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(19772600,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(c19772600.spsumcon)
    e3:SetTarget(c19772600.spsumtg)
    e3:SetOperation(c19772600.spsumop)
    c:RegisterEffect(e3)
    --cannot direct attack
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    e4:SetCondition(c19772600.dircon)
    c:RegisterEffect(e4)
    --lp gain
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(19772600,2))
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(c19772600.lpcon)
    e5:SetCost(c19772600.lpcost)
    e5:SetTarget(c19772600.lptg)
    e5:SetOperation(c19772600.lpop)
    c:RegisterEffect(e5)
    --banish card
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(19772600,3))
    e6:SetCategory(CATEGORY_REMOVE)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_PHASE+PHASE_END)
    e6:SetRange(LOCATION_MZONE)
    e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e6:SetCountLimit(1)
    e6:SetCondition(c19772600.remcon)
    e6:SetCost(c19772600.remcost)
    e6:SetTarget(c19772600.remtg)
    e6:SetOperation(c19772600.remop)
    c:RegisterEffect(e6)
    --pendulum zone
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(19772600,4))
    e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e7:SetCode(EVENT_DESTROYED)
    e7:SetProperty(EFFECT_FLAG_DELAY)
    e7:SetCondition(c19772600.pendlcon)
    e7:SetCost(c19772600.pendlcost)
    e7:SetTarget(c19772600.pendltg)
    e7:SetOperation(c19772600.pendlop)
    c:RegisterEffect(e7)
end
--filter
function c19772600.slfilter(c)
    return c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ)
end
function c19772600.spsumfilter(c,e,tp)
    return c:GetLevel()==4 and c:IsSetCard(0x197) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c19772600.dirfilter(c)
    return c:IsSetCard(0x197) and c:GetLevel()==4
end
--splimit and procedure
function c19772600.splimit(e,se,sp,st)
    return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c19772600.cfilter(c)
    return (c:IsFusionCode(19772599) or c:IsFusionSetCard(0x197) and c:IsType(TYPE_MONSTER))
        and c:IsCanBeFusionMaterial()
end
function c19772600.fcheck(c,sg)
    return c:IsFusionCode(19772599) and sg:IsExists(c19772600.fcheck2,1,c)
end
function c19772600.fcheck2(c)
    return c:IsFusionSetCard(0x197) and c:IsType(TYPE_MONSTER)
end
function c19772600.fselect(c,tp,mg,sg)
    sg:AddCard(c)
    local res=false
    if sg:GetCount()<2 then
        res=mg:IsExists(c19772600.fselect,1,sg,tp,mg,sg)
    elseif Duel.GetLocationCountFromEx(tp,tp,sg)>0 then
        res=sg:IsExists(c19772600.fcheck,1,nil,sg)
    end
    sg:RemoveCard(c)
    return res
end
function c19772600.spcon(e,c)
    if c==nil then return true end
    if c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) then return end
    local tp=c:GetControler()
    local mg=Duel.GetReleaseGroup(tp):Filter(c19772600.cfilter,nil)
    local sg=Group.CreateGroup()
    return mg:IsExists(c19772600.fselect,1,nil,tp,mg,sg)
end
function c19772600.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local mg=Duel.GetReleaseGroup(tp):Filter(c19772600.cfilter,nil)
    local sg=Group.CreateGroup()
    while sg:GetCount()<2 do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        local g=mg:FilterSelect(tp,c19772600.fselect,1,1,sg,tp,mg,sg)
        sg:Merge(g)
    end
    local cg=sg:Filter(Card.IsFacedown,nil)
    if cg:GetCount()>0 then
        Duel.ConfirmCards(1-tp,cg)
    end
    Duel.Release(sg,REASON_COST+REASON_FUSION+REASON_MATERIAL)
end
--scale
function c19772600.slcon(e)
    return Duel.IsExistingMatchingCard(c19772600.slfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
--banish
function c19772600.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
function c19772600.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end
function c19772600.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c19772600.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end
--spsummon from deck
function c19772600.spsumcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c19772600.spsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c19772600.spsumfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c19772600.spsumop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19772600.spsumfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
--cannot direct attack
function c19772600.dircon(e)
    return not Duel.IsExistingMatchingCard(c19772600.dirfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,3,nil)
end
--lp gain
function c19772600.lpcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
function c19772600.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
    Duel.DiscardDeck(tp,1,REASON_COST)
end
function c19772600.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2000)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
function c19772600.lpop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Recover(p,d,REASON_EFFECT)
end
--banish card
function c19772600.remcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function c19772600.remcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end
function c19772600.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c19772600.remop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end
--pendulum zone
function c19772600.pendlcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function c19772600.pendlcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local rg=Duel.GetDecktopGroup(tp,2)
    if chk==0 then return rg:FilterCount(Card.IsAbleToRemove,nil)==2 end
    if rg:GetCount()>1 then
        Duel.Remove(rg,POS_FACEUP,REASON_COST)
    end
end
function c19772600.pendltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function c19772600.pendlop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end