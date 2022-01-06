--Golden Skies - Brandon the Fluid Blade
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    c:EnableReviveLimit()
    --Xyz materials
    aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),7,2)
    --Send a "Golden Skies Treasure" to GY when Fusion Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(cid.tgcon)
    e1:SetTarget(cid.tgtg)
    e1:SetOperation(cid.tgop)
    c:RegisterEffect(e1)
    --Detach a material to attack again
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(cid.atcon)
	e2:SetCost(cid.atcost)
	e2:SetOperation(cid.atop)
	c:RegisterEffect(e2)
end

--Send a "Golden Skies Treasure" to GY when Fusion Summoned

function cid.tgcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function cid.fselect(g)
	return g:GetClassCount(Card.GetOriginalCode)==g:GetCount()
end
function cid.tgfilter(c)
	return c:IsCode(11111040) and c:IsAbleToGrave()
end
function cid.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
	local g=Duel.GetMatchingGroup(cid.tgfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, nil)
	if chk==0 then return g:CheckSubGroup(cid.fselect, 1, 3) end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, 3, 0, 0)
end
function cid.tgop(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(cid.tgfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, nil)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local rg=g:SelectSubGroup(tp,cid.fselect, false, 1, 3)
	Duel.SendtoGrave(rg, REASON_EFFECT)
end

--Detach a material to attack again

function cid.atcon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return aux.bdcon(e, tp, eg, ep, ev, re, r, rp) and c:IsChainAttackable()
end
function cid.atcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end
function cid.atop(e, tp, eg, ep, ev, re, r, rp)
	Duel.ChainAttack()
end