--Shisune Kannushi
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion materials
	aux.AddFusionProcFunRep(c, cid.ffilter, 2, true)
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost, LOCATION_MZONE+LOCATION_GRAVE, 0, aux.tdcfop(c))
	--Must be Fusion Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(cid.splimit)
    c:RegisterEffect(e1)
    --Excavate and add to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(cid.condition)
	e2:SetCost(cid.cost)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
    c:RegisterEffect(e2)
    --Copy a ritual spell in GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_DECK)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id+100)
    e3:SetCondition(cid.cpcon)
    e3:SetTarget(cid.cptg)
    e3:SetOperation(cid.cpop)
    c:RegisterEffect(e3)
end

--Must be Fuison Summoned

function cid.splimit(e, se, sp, st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end

--Fusion materials

function cid.ffilter(c, fc, sub, mg, sg)
	return c:IsFusionSetCard(0x570) and c:IsType(TYPE_MONSTER) and (not sg or not sg:IsExists(Card.IsFusionCode, 1, c, c:GetFusionCode()))
end

--Excavate and add to hand

function cid.confilter(c)
    return c:IsFaceup() and c:IsSetCard(0x570) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL)
end
function cid.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(cid.confilter, tp, LOCATION_MZONE, 0, 1, nil)
end
function cid.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(), REASON_COST)
end
function cid.filter(c)
	return c:IsSetCard(0x570) and c:IsAbleToHand()
end
function cid.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp, 3)
		and Duel.GetDecktopGroup(tp, 3):FilterCount(Card.IsAbleToHand, nil)>0 end
end
function cid.operation(e, tp, eg, ep, ev, re, r, rp)
	if not Duel.IsPlayerCanDiscardDeck(tp, 3) then return end
	Duel.ConfirmDecktop(tp, 3)
	local g=Duel.GetDecktopGroup(tp, 3)
	if g:GetCount()>0 then
		Duel.DisableShuffleCheck()
		if g:IsExists(cid.filter, 1, nil) then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
			local sg=g:FilterSelect(tp, cid.filter, 1, 1, nil)
			Duel.SendtoHand(sg, nil, REASON_EFFECT)
			Duel.ConfirmCards(1-tp, sg)
			Duel.ShuffleHand(tp)
			g:Sub(sg)
		end
		Duel.SendtoGrave(g, REASON_EFFECT+REASON_REVEAL)
	end
end

--Copy a ritual spell in GY

function cid.cfilter(c, tp)
    return c:IsSetCard(0x570) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_GRAVE)
end
function cid.cpcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(cid.cfilter, 1, nil, tp)
end
function cid.cpfilter(c)
	return c:IsSetCard(0x570) and c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToDeck() and c:CheckActivateEffect(true, true, false)~=nil
end
function cid.cptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg(e, tp, eg, ep, ev, re, r, rp, 0, chkc)
	end
	if chk==0 then
		e:SetLabel(0)
		return e:GetHandler():IsAbleToDeck() and Duel.IsExistingMatchingCard(cid.cpfilter, tp, LOCATION_GRAVE, 0, 1, nil)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp, cid.cpfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	local te=g:GetFirst():CheckActivateEffect(true, true, false)
	e:SetLabelObject(te)
	g:AddCard(e:GetHandler())
	Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e, tp, eg, ep, ev, re, r, rp, 1) end
	Duel.ClearOperationInfo(0)
end
function cid.cpop(e, tp, eg, ep, ev, re, r, rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e, tp, eg, ep, ev, re, r, rp) end
end
