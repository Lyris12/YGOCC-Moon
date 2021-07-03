--Grey Blood Crisis Claw - Insanity
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
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	aux.AddOrigEvoluteType(c)
	--Evolute material
	aux.AddEvoluteProc(c, nil, 4, cid.matfilter, 1, 1)
	--Cannot be destroyed by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Attribute change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(0x1f)
	e2:SetCondition(cid.attcon)
	c:RegisterEffect(e2)
	--Shuffle and equip
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_EQUIP)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(cid.eqcon)
	e3:SetTarget(cid.eqtg)
	e3:SetOperation(cid.eqop)
	c:RegisterEffect(e3)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(cid.descon)
	e4:SetCost(cid.descost)
	e4:SetTarget(cid.destg)
	e4:SetOperation(cid.desop)
	c:RegisterEffect(e4)
end
--Evolute material
function cid.matfilter(c)
	return c:IsSetCard(0x571) and c:GetEquipCount()>0
end
--Attribute change
function cid.attcon(e)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard, 1, nil, 0x571)
end
--shuffle and equip
function cid.eqcon(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388
end
function cid.tdfilter(c, tp)
	return c:IsSetCard(0x571) and c:IsType(TYPE_EQUIP) and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(cid.eqfilter, tp, LOCATION_DECK, 0, 1, nil, c:GetCode())
end
function cid.eqfilter(c, code)
	return c:IsSetCard(0x571) and c:IsType(TYPE_EQUIP) and not c:IsCode(code)
end
function cid.eqtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cid.tdfilter, tp, LOCATION_GRAVE, 0, 1, nil, tp)
		and Duel.IsExistingMatchingCard(cid.eqfilter, tp,LOCATION_DECK, 0, 1, nil, e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp, cid.tdfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, tp)
	Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, tp, LOCATION_DECK)
end
function cid.eqop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local code=tc:GetCode()
	if Duel.GetLocationCount(tp, LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc, nil, 2, REASON_EFFECT)~=0 then
		if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp, cid.eqfilter, tp, LOCATION_DECK, 0, 1, 1, nil, code, c)
		local sg=g:GetFirst()
		if sg then
			Duel.Equip(tp, sg, c)
		end
	end
end
--Destroy
function cid.cfilter(c, ec, tp)
	return c:IsSetCard(0x571) and c:IsType(TYPE_EQUIP) and c:IsControler(tp) and c:GetEquipTarget()==ec
end
function cid.descon(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(cid.cfilter, 1, nil, e:GetHandler(), tp)
end
function cid.descost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp, 2, REASON_COST) end
	e:GetHandler():RemoveEC(tp, 2, REASON_COST)
end
function cid.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end
function cid.desop(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc, REASON_EFFECT)
	end
end