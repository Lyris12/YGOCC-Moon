--Mekbuster VECTOR Frame Development
function c67864655.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67864655,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,67864655)
	e1:SetTarget(c67864655.sptg)
	e1:SetOperation(c67864655.spop)
	c:RegisterEffect(e1)
	--tadd to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67864655,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,67864655+100)
	e2:SetCost(c67864655.tdcost)
	e2:SetTarget(c67864655.tdtg)
	e2:SetOperation(c67864655.tdop)
	c:RegisterEffect(e2)
end
function c67864655.mfilter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
function c67864655.mfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function c67864655.mfilter2(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function c67864655.spfilter1(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE+RACE_WARRIOR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c67864655.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE+RACE_WARRIOR) and c:IsSetCard(0x2a6) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c67864655.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
        local chkf=tp
        local mg1=Duel.GetFusionMaterial(tp)
        local res=Duel.IsExistingMatchingCard(c67864655.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
        if res then return true end
        local mg2=Duel.GetMatchingGroup(c67864655.mfilter0,tp,LOCATION_GRAVE,0,nil)
        mg2:Merge(mg1)
        res=Duel.IsExistingMatchingCard(c67864655.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,nil,chkf)
        if not res then
            local ce=Duel.GetChainMaterial(tp)
            if ce~=nil then
                local fgroup=ce:GetTarget()
                local mg3=fgroup(ce,e,tp)
                local mf=ce:GetValue()
                res=Duel.IsExistingMatchingCard(c67864655.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
            end
        end
        return res
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c67864655.spop(e,tp,eg,ep,ev,re,r,rp)
    local chkf=tp
    local mg1=Duel.GetFusionMaterial(tp):Filter(c67864655.mfilter1,nil,e)
    local sg1=Duel.GetMatchingGroup(c67864655.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
    local mg2=Duel.GetMatchingGroup(c67864655.mfilter2,tp,LOCATION_GRAVE,0,nil,e)
    mg2:Merge(mg1)
    local sg2=Duel.GetMatchingGroup(c67864655.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,nil,chkf)
    sg1:Merge(sg2)
    local mg3=nil
    local sg3=nil
    local ce=Duel.GetChainMaterial(tp)
    if ce~=nil then
        local fgroup=ce:GetTarget()
        mg3=fgroup(ce,e,tp)
        local mf=ce:GetValue()
        sg3=Duel.GetMatchingGroup(c67864655.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
    end
    if sg1:GetCount()>0 or (sg3~=nil and sg3:GetCount()>0) then
        local sg=sg1:Clone()
        if sg3 then sg:Merge(sg3) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=sg:Select(tp,1,1,nil)
        local tc=tg:GetFirst()
        if sg1:IsContains(tc) and (sg3==nil or not sg3:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
            if tc:IsSetCard(0x2a6) then
                local mat1=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
                tc:SetMaterial(mat1)
                local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
                mat1:Sub(mat2)
                Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
                Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            else
                local mat2=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
                tc:SetMaterial(mat2)
                Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            end
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        else
            local mat=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
            local fop=ce:GetOperation()
            fop(ce,e,tp,tc,mat)
        end
        tc:CompleteProcedure()
    end
end
function c67864655.tdfilter(c)
	return c:IsSetCard(0x2a6) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c67864655.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c67864655.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c67864655.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c67864655.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c67864655.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,2,REASON_EFFECT)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end