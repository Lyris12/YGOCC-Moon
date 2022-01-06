--Golden Skies Treasure of War
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    --Destroy a face-up card if sent to GY by a "Golden Skies" card effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(cid.descon)
	e1:SetTarget(cid.destg)
	e1:SetOperation(cid.desop)
    c:RegisterEffect(e1)
end

--Destroy a face-up card if sent to GY by a "Golden Skies" card effect

function cid.descon(e, tp, eg, ep, ev, re, r, rp)
	return re:GetHandler():IsSetCard(0x528) and bit.band(r, REASON_EFFECT)~=0
end
function cid.destg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
	local g=Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end
function cid.desop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g, REASON_EFFECT)
	end
end