--Crisis Clawspirit - Pegasus' Arrogance
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
	c:SetUniqueOnField(1, 0, cid.uniquefilter, LOCATION_SZONE)
	--Special Summon and equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_EQUIP_LIMIT)
	e0:SetLabel(0)
	e0:SetValue(cid.eqlimit)
	c:RegisterEffect(e0)
	--Update ATK&DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(cid.attcon)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Untargetable
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetCondition(cid.attcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--Destroy this card during the end phase
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCountLimit(1)
	e5:SetTarget(cid.destg1)
	e5:SetOperation(cid.desop1)
	c:RegisterEffect(e5)
	--Destroy the equipped monster
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(cid.descon)
	e6:SetTarget(cid.destg2)
	e6:SetOperation(cid.desop2)
	c:RegisterEffect(e6)
end
--Special Summon and equip
function cid.filter(c, e, tp)
	return c:IsSetCard(0x571) and (c:IsOnField() or Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false))
end
function cid.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(tp) and cid.filter(chkc, e, tp) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter, tp, LOCATION_GRAVE+LOCATION_MZONE, 0, 1, nil, e, tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local tc=Duel.SelectTarget(tp, cid.filter, tp, LOCATION_GRAVE+LOCATION_MZONE, 0, 1, 1, nil, e, tp):GetFirst()
	if tc:IsOnField() then Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, tc, 1, 0, 0) end
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, e:GetHandler(), 1, 0, 0)
end
function cid.activate(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if tc:IsLocation(LOCATION_GRAVE) and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)==0 then return end
		Duel.Equip(tp, c, tc)
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabel(1)
		e1:SetValue(cid.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function cid.eqlimit(e, c)
	if e:GetLabel()>0 then return e:GetOwner()==c
	else return c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x571) end
end
--Update ATK&DEF/Untargetable
function cid.attcon(e, c)
	local c=e:GetHandler()
	return c:GetEquipTarget():IsAttribute(ATTRIBUTE_LIGHT)
end
--Destroy this card during the end phase
function cid.destg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, e:GetHandler(), 1, 0, 0)
end
function cid.desop1(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Destroy(c, REASON_EFFECT)
	end
end
--Destroy the equipped monster
function cid.descon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function cid.destg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetPreviousEquipTarget()
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, tc, 1, 0, 0)
end
function cid.desop2(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end