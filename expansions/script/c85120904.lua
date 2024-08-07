--created by LeonDuvall, coded by Lyris, fixed by XGlitchy30
--Helios - Reformation of the Sun
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigTimeleapType(c)
	aux.AddCodeList(c,CARD_MACRO_COSMOS,CARD_HELIOS_TRICE_MEGISTUS)
	aux.AddTimeleapProc(c,9,s.mcon,aux.FilterBoolFunction(Card.IsCode,CARD_HELIOS_TRICE_MEGISTUS))
	--This card's name becomes "Helios - The Primordial Sun" while on the field, in the GY or while it is banished.
	local e0=aux.EnableChangeCode(c,CARD_HELIOS_THE_PRIMORDIAL_SUN,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	--This card's original ATK/DEF are equal to the number of banished cards x 700.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.adval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	--This card can attack all monsters your opponent controls, once each.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--If this card is destroyed, or banished, by battle or card effect: Special Summon this card, and if you do, it gains 700 ATK/DEF.
	local e4=Effect.CreateEffect(c)
	e4:Desc(0)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORIES_ATKDEF)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	e5:SetCondition(s.spcon2)
	c:RegisterEffect(e5)
end
function s.mcon(e,tl,tp)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_MACRO_COSMOS),tp,LOCATION_ONFIELD,0,1,nil)
end

--E1
function s.adval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_REMOVED,LOCATION_REMOVED)*700
end

--E4
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_BATTLE|REASON_EFFECT)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_DESTROY)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,c,1,tp,LOCATION_MZONE,700)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		e1:SetValue(700)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end
