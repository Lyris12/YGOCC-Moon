--Asmitala
local x=888015
local cx=_G["c"..x]
function cx.initial_effect(c)
    aux.EnablePendulumAttribute(c)
    c:EnableReviveLimit()
    aux.AddFusionProcFunRep(c,cx.ffilter,2,false)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(cx.splimit)
    c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(cx.spcon)
    e1:SetOperation(cx.spop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetDescription(aux.Stringid(x,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_PZONE)
    e2:SetTarget(cx.target)
    e2:SetOperation(cx.activate)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(x,0))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(cx.tgcon)
    e3:SetCountLimit(1,888115)
    e3:SetTarget(cx.tgtg)
    e3:SetOperation(cx.tgop)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(x,2))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCountLimit(1,x)
    e4:SetCondition(cx.pencon)
    e4:SetTarget(cx.pentg)
    e4:SetOperation(cx.penop)
    c:RegisterEffect(e4)
end

function cx.cfilter(c)
    return c:IsFacedown() or not c:IsRace(RACE_PLANT)
end
function cx.pencon(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(cx.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function cx.dfilter(c)
    return c:IsSetCard(0xffa) and c:IsLevelAbove(1) and c:IsAbleToGrave()
end
function cx.filter(c,e,tp,m,ft)
    if not c:IsSetCard(0xffa) or bit.band(c:GetType(),0x81)~=0x81
        or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
    local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
    local dg=Duel.GetMatchingGroup(cx.dfilter,tp,LOCATION_EXTRA,0,nil)
    if ft>0 then
        return mg:CheckWithSumEqual(Card.GetRitualLevel,c:GetLevel(),1,99,c)
            or dg:IsExists(cx.dlvfilter,1,nil,tp,mg,c)
    else
        return ft>-1 and mg:IsExists(cx.mfilterf,1,nil,tp,mg,dg,c)
    end
end
function cx.mfilterf(c,tp,mg,dg,rc)
    if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
        Duel.SetSelectedCard(c)
        return mg:CheckWithSumEqual(Card.GetRitualLevel,rc:GetLevel(),0,99,rc)
            or dg:IsExists(cx.dlvfilter,1,nil,tp,mg,rc,c)
    else return false end
end
function cx.dlvfilter(c,tp,mg,rc,mc)
    Duel.SetSelectedCard(Group.FromCards(c,mc))
    return mg:CheckWithSumEqual(Card.GetRitualLevel,rc:GetLevel(),0,99,rc)
end
function cx.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetRitualMaterial(tp)
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        return Duel.IsExistingMatchingCard(cx.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,mg,ft)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cx.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local m=Duel.GetRitualMaterial(tp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cx.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,m,ft)
    local tc=tg:GetFirst()
    if tc then
        local mat,dmat
        local mg=m:Filter(Card.IsCanBeRitualMaterial,tc,tc)
        local dg=Duel.GetMatchingGroup(cx.dfilter,tp,LOCATION_EXTRA,0,nil)
        if ft>0 then
            local b1=dg:IsExists(cx.dlvfilter,1,nil,tp,mg,tc)
            local b2=mg:CheckWithSumEqual(Card.GetRitualLevel,tc:GetLevel(),1,99,tc)
            if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(x,0))) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                dmat=dg:FilterSelect(tp,cx.dlvfilter,1,1,nil,tp,mg,tc)
                Duel.SetSelectedCard(dmat)
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
                mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),0,99,tc)
                mat:Merge(dmat)
            else
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
                mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),1,99,tc)
            end
        else
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
            mat=mg:FilterSelect(tp,cx.mfilterf,1,1,nil,tp,mg,dg,tc)
            local b1=dg:IsExists(cx.dlvfilter,1,nil,tp,mg,tc,mat:GetFirst())
            Duel.SetSelectedCard(mat)
            local b2=mg:CheckWithSumEqual(Card.GetRitualLevel,tc:GetLevel(),0,99,tc)
            if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(x,0))) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                dmat=dg:FilterSelect(tp,cx.dlvfilter,1,1,nil,tp,mg,tc,mat:GetFirst())
                mat:Merge(dmat)
                Duel.SetSelectedCard(mat)
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
                local mat2=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),0,99,tc)
                mat:Merge(mat2)
            else
                Duel.SetSelectedCard(mat)
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
                local mat2=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),0,99,tc)
                mat:Merge(mat2)
            end
        end
        tc:SetMaterial(mat)
        if dmat then
            mat:Sub(dmat)
            Duel.SendtoGrave(dmat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
        end
        Duel.ReleaseRitualMaterial(mat)
        Duel.BreakEffect()
        Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
        tc:CompleteProcedure()
        Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
    end
end
function cx.ffilter(c)
    return c:IsSetCard(0xffa)
end
function cx.splimit(e,se,sp,st)
    return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function cx.spfilter(c,fc)
    return cx.ffilter(c) and c:IsCanBeFusionMaterial(fc)
end
function cx.spfilter1(c,tp,g)
    return g:IsExists(cx.spfilter2,1,c,tp,c)
end
function cx.spfilter2(c,tp,mc)
    return Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(c,mc))>0
end
function cx.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetReleaseGroup(tp):Filter(cx.spfilter,nil,c)
    return g:IsExists(cx.spfilter1,1,nil,tp,g)
end
function cx.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.GetReleaseGroup(tp):Filter(cx.spfilter,nil,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g1=g:FilterSelect(tp,cx.spfilter1,1,1,nil,tp,g)
    local mc=g1:GetFirst()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g2=g:FilterSelect(tp,cx.spfilter2,1,1,mc,tp,mc)
    g1:Merge(g2)
    c:SetMaterial(g1)
    Duel.Release(g1,REASON_COST+REASON_FUSION+REASON_MATERIAL)
end
function cx.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL
end
function cx.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(cx.filter3,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,cx.filter3,tp,LOCATION_ONFIELD,0,1,2,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function cx.tgop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    Duel.SendtoHand(g,nil,REASON_EFFECT)
end
function cx.filter3(c)
    return c:IsFaceup() and c:IsSetCard(0xffa) and c:IsAbleToHand()
end
function cx.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function cx.penop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
