--created & coded by Lyris, art from Cardfight!! Vanguard's "Crimson Beast Tamer"
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(function(e,c) return Duel.GetOverlayGroup(e:GetHandlerPlayer(),1,0):Filter(Card.IsSetCard,nil,0xc74):GetClassCount(Card.GetCode)*200 end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCondition(aux.dscon)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanOverlay(tp)
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,0,1,nil,TYPE_XYZ) end
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsType),tp,LOCATION_MZONE,0,nil,TYPE_XYZ)
	if not c:IsRelateToEffect(e) or #g==0 then return end
	Duel.Overlay(g:Select(tp,1,1,nil):GetFirst(),c)
	if not c:IsLocation(LOCATION_OVERLAY) then return end
	for tc in aux.Next(Duel.GetFieldGroup(tp,LOCATION_MZONE,0)) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(function(ef,tc) return Duel.GetOverlayGroup(ef:GetHandlerPlayer(),1,0):Filter(Card.IsSetCard,nil,0xc74):GetClassCount(Card.GetCode)*400 end)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
