--Grey Blood Crisis Claw - Insanity
--Scripted by Yuno, overhauled by Swag
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	aux.AddFusionProcMixRep(c,false,true,cid.matfilter,1,1)
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
	e4:SetTarget(cid.destg)
	e4:SetOperation(cid.desop)
	c:RegisterEffect(e4)
	--Summon Condition
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(cid.splimit)
	c:RegisterEffect(e5)
	--Actually summoning the fucking thing
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(cid.hspcon)
	e3:SetOperation(cid.hspop)
	c:RegisterEffect(e3)
end
--Material
function cid.matfilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x571) and c:GetEquipGroup():IsExists(Card.IsType,1,nil,TYPE_EQUIP)
end
--Attribute change
function cid.attcon(e)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard, 1, nil, 0x571)
end
--shuffle and equip
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
function cid.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function cid.hspcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),cid.matfilter,1,nil,c:GetControler(),c)
end
function cid.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,cid.matfilter,1,1,nil,tp,c)
	c:SetMaterial(g)
	Duel.Release(g,REASON_COST)
end