function c210216002.initial_effect(c)
	c:EnableReviveLimit()
	--cannot disable effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_DISABLE)
	c:RegisterEffect(e1)
	--spsummon limit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(c210216002.splimit)
	c:RegisterEffect(e5)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c210216002.atkval)
	c:RegisterEffect(e3)
	--attach
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c210216002.sptg)
	e4:SetOperation(c210216002.spop)
	c:RegisterEffect(e4)
end
function c210216002.splimit(e,se,sp,st)
	return (se:GetHandler():IsSetCard(0x216) and se:GetHandler():IsType(TYPE_TRAP)) or e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c210216002.filter(c)
	return c:IsSetCard(0x216) and c:IsType(TYPE_TRAP)
end
function c210216002.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c210216002.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c210216002.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local g=Duel.SelectTarget(tp,c210216002.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
function c210216002.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		then
		Duel.Overlay(c,Group.FromCards(tc))
end
end
function c210216002.atkval(e,c)
	return c:GetOverlayCount()*1000
end