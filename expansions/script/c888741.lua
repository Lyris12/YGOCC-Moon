--Star Bearer's Veil
local m=888741
local cm=_G["c"..m]
function cm.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(cm.target)
    e1:SetOperation(cm.activate)
    c:RegisterEffect(e1)
    --bfg
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(21501505,0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(cm.condition)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(cm.tg)
    e2:SetOperation(cm.operation)
    c:RegisterEffect(e2)
end

function cm.filter1(c,e)
    return c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and c:IsType(TYPE_MONSTER)
end
function cm.exfilter0(c)
    return c:IsSetCard(0xff1) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
end
function cm.exfilter1(c,e)
    return c:IsSetCard(0xff1) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave() and not c:IsImmuneToEffect(e) and c:IsType(TYPE_MONSTER)
end
function cm.filter2(c,e,tp,m,f,chkf)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0xff1) and (not f or f(c))
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function cm.fcheck(tp,sg,fc)
    return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local chkf=tp
        local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToGrave,nil)
        if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=0 then
            local sg=Duel.GetMatchingGroup(cm.exfilter0,tp,LOCATION_DECK,0,nil)
            if sg:GetCount()>0 then
                mg1:Merge(sg)
                Auxiliary.FCheckAdditional=cm.fcheck
            end
        end
        local res=Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
        Auxiliary.FCheckAdditional=nil
        Auxiliary.GCheckAdditional=nil
        if not res then
            local ce=Duel.GetChainMaterial(tp)
            if ce~=nil then
                local fgroup=ce:GetTarget()
                local mg2=fgroup(ce,e,tp)
                local mf=ce:GetValue()
                res=Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
            end
        end
        return res
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
    local chkf=tp
    local mg1=Duel.GetFusionMaterial(tp):Filter(cm.filter1,nil,e)
    local exmat=false
    if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=0 then
        local sg=Duel.GetMatchingGroup(cm.exfilter1,tp,LOCATION_DECK,0,nil,e)
        if sg:GetCount()>0 then
            mg1:Merge(sg)
            exmat=true
        end
    end
    if exmat then
        Auxiliary.FCheckAdditional=cm.fcheck
    end
    local sg1=Duel.GetMatchingGroup(cm.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
    Auxiliary.FCheckAdditional=nil
    Auxiliary.GCheckAdditional=nil
    local mg2=nil
    local sg2=nil
    local ce=Duel.GetChainMaterial(tp)
    if ce~=nil then
        local fgroup=ce:GetTarget()
        mg2=fgroup(ce,e,tp)
        local mf=ce:GetValue()
        sg2=Duel.GetMatchingGroup(cm.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
    end
    if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
        local sg=sg1:Clone()
        if sg2 then sg:Merge(sg2) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=sg:Select(tp,1,1,nil)
        local tc=tg:GetFirst()
        mg1:RemoveCard(tc)
        if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
            if exmat then
                Auxiliary.FCheckAdditional=cm.fcheck
            end
            local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
            Auxiliary.FCheckAdditional=nil
            Auxiliary.GCheckAdditional=nil
            tc:SetMaterial(mat1)
            Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        else
            local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
            local fop=ce:GetOperation()
            fop(ce,e,tp,tc,mat2)
        end
        tc:CompleteProcedure()
    end
end

function cm.condition(e,tp,eg,ep,ev,re,r,rp)
    if e==re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    if not g or g:GetCount()~=1 then return false end
    local tc=g:GetFirst()
    e:SetLabelObject(tc)
    return tc:IsOnField() and g:IsExists(cm.tfilter,1,nil,tp)
end
function cm.tfilter(c)
    return c:IsSetCard(0xff1)
end
function cm.tffilter(c,re,rp,tf,ceg,cep,cev,cre,cr,crp)
    return tf(re,rp,ceg,cep,cev,cre,cr,crp,0,c)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local ct=ev
    local label=Duel.GetFlagEffectLabel(0,21501505)
    if label then
        if ev==bit.rshift(label,16) then ct=bit.band(label,0xffff) end
    end
    local ce,cp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
    local tf=ce:GetTarget()
    local ceg,cep,cev,cre,cr,crp=Duel.GetChainEvent(ct)
    if chkc then return chkc:IsOnField() and cm.tffilter(chkc,ce,cp,tf,ceg,cep,cev,cre,cr,crp) end
    if chk==0 then return Duel.IsExistingTarget(cm.tffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetLabelObject(),ce,cp,tf,ceg,cep,cev,cre,cr,crp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,cm.tffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetLabelObject(),ce,cp,tf,ceg,cep,cev,cre,cr,crp)
    local val=ct+bit.lshift(ev+1,16)
    if label then
        Duel.SetFlagEffectLabel(0,21501505,val)
    else
        Duel.RegisterFlagEffect(0,21501505,RESET_CHAIN,0,1,val)
    end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.ChangeTargetCard(ev,Group.FromCards(tc))
    end
end
