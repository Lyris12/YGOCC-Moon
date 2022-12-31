--Asmitala Branchia 
local x=888002
local cx=_G["c"..x]
function cx.initial_effect(c)
    aux.EnablePendulumAttribute(c)
    c:EnableReviveLimit()
    --Ritual Summon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetDescription(aux.Stringid(x,1))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetCountLimit(1)
    e1:SetRange(LOCATION_PZONE)
    e1:SetTarget(cx.target)
    e1:SetOperation(cx.activate)
    c:RegisterEffect(e1)
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
    end
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e3:SetTargetRange(1,0)
    e3:SetTarget(cx.splimit)
    e3:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e3,tp)
end

function cx.splimit(e,c,tp,sumtp,sumpos)
    return c:GetRace()~=RACE_PLANT
end