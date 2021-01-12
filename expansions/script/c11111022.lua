--Golden Skies - Eiza the Treasure Smith
--Scripted by Yuno
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
    --Reveal a "Golden Skies" card and Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(cid.spcost)
    e1:SetTarget(cid.sptg)
    e1:SetOperation(cid.spop)
    c:RegisterEffect(e1)
    --Shuffle "Golden Skies Treasure" and Fusion Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id+100)
    e2:SetTarget(cid.tdtg)
    e2:SetOperation(cid.tdop)
    c:RegisterEffect(e2)
end

--Reveal a "Golden Skies" card and Special Summon

function cid.spfilter(c)
	return (c:IsSetCard(0x528) and not c:IsCode(id)) and not c:IsPublic()
end
function cid.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.spfilter, tp, LOCATION_HAND, 0, 1, e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp, cid.spfilter, tp, LOCATION_HAND, 0, 1, 1, e:GetHandler())
	Duel.ConfirmCards(1-tp, g)
	Duel.ShuffleHand(tp)
end
function cid.tgfilter(c, tp, mc)
	local g=Group.FromCards(c)
	if mc then g:AddCard(mc) end
	return c:IsCode(11111040) and c:IsAbleToGrave() and Duel.GetMZoneCount(tp, g)>0
end
function cid.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.tgfilter, tp, LOCATION_DECK, 0, 1, nil) 
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function cid.spop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, cid.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil, tp)
	if g:GetCount()>0 and Duel.SendtoGrave(g, REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
        --Special Summon Limit
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1, 0)
        e1:SetTarget(cid.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end
function cid.splimit(e, c)
    return not c:IsRace(RACE_WARRIOR)
end

--Shuffle "Golden Skies Treasure" and Fusion Summon

function cid.tdfilter(c)
	return c:IsCode(11111040) and c:IsAbleToDeck()
end
function cid.spfilter1(c, e)
	return not c:IsImmuneToEffect(e)
end
function cid.spfilter2(c, e, tp, m, f, chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_WARRIOR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function cid.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND+LOCATION_GRAVE)
end
function cid.tdop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, cid.tdfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, 1, nil, tp)
    if g:GetCount()>0 then
        local sg=g:GetFirst()
        if Duel.SendtoDeck(g, tp, 2, REASON_EFFECT)~=0 and sg:IsLocation(LOCATION_DECK) and Duel.ShuffleDeck(tp)~=0 then
            local chkf=tp
            local mg1=Duel.GetFusionMaterial(tp):Filter(cid.spfilter1, nil, e)
            local sg1=Duel.GetMatchingGroup(cid.spfilter2, tp, LOCATION_EXTRA, 0, nil, e, tp, mg1, nil, chkf)
            local mg2=nil
            local sg2=nil
            local ce=Duel.GetChainMaterial(tp)
            if ce~=nil then
                local fgroup=ce:GetTarget()
                mg2=fgroup(ce, e, tp)
                local mf=ce:GetValue()
                sg2=Duel.GetMatchingGroup(cid.spfilter2, tp, LOCATION_EXTRA, 0, nil, e, tp, mg2, mf, chkf)
            end
            if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
                local sg=sg1:Clone()
                if sg2 then sg:Merge(sg2) end
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
                local tg=sg:Select(tp, 1, 1, nil)
                local tc=tg:GetFirst()
                if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp, ce:GetDescription())) then
                    local mat1=Duel.SelectFusionMaterial(tp, tc, mg1, nil, chkf)
                    tc:SetMaterial(mat1)
                    Duel.SendtoGrave(mat1, REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
                    Duel.BreakEffect()
                    Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
                else
                    local mat2=Duel.SelectFusionMaterial(tp, tc, mg2, nil, chkf)
                    local fop=ce:GetOperation()
                    fop(ce, e, tp, tc, mat2)
                end
                tc:CompleteProcedure()
            end
        end
    end
end