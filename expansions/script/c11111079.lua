--The Shisune's Outrage
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
	aux.AddCodeList(c, 11111081, 11111082)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(cid.condition)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
    c:RegisterEffect(e1)
    --Add back a ritual monster from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(cid.thcon)
    e2:SetCost(cid.thcost)
    e2:SetTarget(cid.thtg)
    e2:SetOperation(cid.thop)
    c:RegisterEffect(e2)
end

--Activate

function cid.confilter(c)
    return c:IsFaceup() and c:IsCode(11111081) or c:IsCode(11111082)
end
function cid.condition(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(cid.confilter, tp, LOCATION_MZONE, 0, 1, nil)
	    or not c:IsStatus(STATUS_SET_TURN) and not c:IsLocation(LOCATION_HAND)
end
function cid.mfilter(c, e)
	return c:GetLevel()>0 and not c:IsImmuneToEffect(e) and c:IsReleasable()
end
function cid.filter(c, e, tp)
	return c:IsSetCard(0x570)
end
function cid.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then
		local mg1=Duel.GetRitualMaterial(tp)
		mg1:Remove(Card.IsLocation, nil, LOCATION_HAND)
		local mg2=Duel.GetMatchingGroup(cid.mfilter, tp, LOCATION_HAND+LOCATION_MZONE, 0, nil, e)
		mg1:Merge(mg2)
        return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter, tp, LOCATION_HAND, 0, 1, nil, cid.filter, e, tp, mg1, nil, Card.GetLevel, "Equal")
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
end
function cid.activate(e, tp, eg, ep, ev, re, r, rp)
	local mg1=Duel.GetRitualMaterial(tp)
	mg1:Remove(Card.IsLocation, nil, LOCATION_HAND)
	local mg2=Duel.GetMatchingGroup(cid.mfilter, tp, LOCATION_HAND+LOCATION_MZONE, 0, nil, e)
	mg1:Merge(mg2)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp, aux.RitualUltimateFilter, tp, LOCATION_HAND, 0, 1, 1, nil, cid.filter, e, tp, mg1, nil, Card.GetLevel, "Equal")
	local tc=tg:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial, tc, tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter, tc, tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc, tc:GetLevel(), "Equal")
		local mat=mg:SelectSubGroup(tp, aux.RitualCheck, false, 1, tc:GetLevel(), tp, tc, tc:GetLevel(), "Equal")
		aux.GCheckAdditional=nil
		if not mat or mat:GetCount()==0 then return end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		--Cannot be destroyed by battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
		---Cannot be destroyed by card effects
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e2)
        Duel.SpecialSummon(tc, SUMMON_TYPE_RITUAL, tp, tp, false, true, POS_FACEUP)
        tc:CompleteProcedure()
		local g=Duel.GetMatchingGroup(Card.IsAbleToGrave, tp, 0, LOCATION_ONFIELD, nil)
		if g:GetCount()>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
			local sg=g:Select(tp, 1, 1, nil)
			Duel.HintSelection(sg)
			Duel.SendtoGrave(sg, REASON_EFFECT)
		end
	end
end

--Add back a ritual monster from GY

function cid.cfilter(c)
	return c:IsFacedown() or not (c:IsSetCard(0x570) and c:IsType(TYPE_RITUAL))
end
function cid.thcon(e, tp, eg, ep, ev, re, r, rp)
	return not Duel.IsExistingMatchingCard(cid.cfilter, tp, LOCATION_MZONE, 0, 1, nil)
end
function cid.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(), nil, 2, REASON_EFFECT)
end
function cid.thfilter(c)
	return c:IsSetCard(0x570) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
function cid.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and cid.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.thfilter, tp,LOCATION_GRAVE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp, cid.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end
function cid.thop(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, tc)
	end
end
