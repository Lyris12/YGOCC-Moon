--[[
Invernal of the Blazing Caestus
Invernale del Caestus Fiammante
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If you control no monsters, or if you control an "Invernal" monster, except "Invernal of the Blazing Caestus": You can send the top card of your Deck to the GY;
	Special Summon this card from your hand or GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		s.spcon,
		s.spcost,
		xgl.SpecialSummonSelfTarget(),
		xgl.SpecialSummonSelfOperation()
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can Special Summon 1 "Invernal" monster from your Deck, except "Invernal of the Blazing Caestus",
	but its effects are negated until the end of the turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetFunctions(
		nil,
		nil,
		xgl.SpecialSummonTarget(false,s.spfilter,LOCATION_DECK,0,1,1,nil),
		xgl.SpecialSummonOperation({Duel.SpecialSummonNegate,RESET_PHASE|PHASE_END},false,s.spfilter,LOCATION_DECK,0,1,1,nil)
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[A DARK "Number" Xyz Monster that has this card attached to it as material gains this effect.
	● This card gains ATK equal to half of its original ATK.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.xmatcon)
	e3:SetValue(s.xmatval)
	c:RegisterEffect(e3)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and s.spfilter(c)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	Duel.DiscardDeck(tp,1,REASON_COST)
end

--E2
function s.spfilter(c)
	return c:IsSetCard(ARCHE_INVERNAL) and not c:IsCode(id)
end

--E3
function s.xmatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.xmatval(e,c)
	return e:GetHandler():GetBaseAttack()/2
end