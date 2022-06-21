--Clockwork Castle
--Keddy was here~
local cod,id=GetID()
function cod.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cod.actcon)
	c:RegisterEffect(e1)
	--Name
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetValue(0x593)
	c:RegisterEffect(e2)
	--Link
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(cod.lktg)
	e3:SetOperation(cod.lkop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(id)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e4:SetLabelObject(e3)
	e4:SetTarget(cod.target)
	c:RegisterEffect(e4)
	--1 Extra NS
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e5:SetTarget(cod.extg)
	c:RegisterEffect(e5)
end

function cod.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cod.lfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function cod.lfilter(c)
	if c:IsHasEffect(id) then return false
	else return c:IsSetCard(0x593) and c:IsType(TYPE_MONSTER) and not c:IsLinkState() end
end
function cod.lktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and cod.lfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cod.lfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,cod.lfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
function cod.lkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() then
		tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(39507190,0))
	end
end
function cod.target(e,c)
	return c:GetFlagEffect(id)>0
end

function cod.extg(e,c)
	return c:IsSetCard(0x593)
end