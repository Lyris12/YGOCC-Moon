--[[
Invernal of the Serrated Knives
Invernale dei Coltelli Serrati
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
	--[[If this card is Normal or Special Summoned: You can Special Summon 1 "Invernal" monster from your hand or GY, except "Invernal of the Serrated Knives".]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetFunctions(
		nil,
		nil,
		xgl.SpecialSummonTarget(false,s.spfilter,LOCATION_HAND|LOCATION_GRAVE,1,nil),
		xgl.SpecialSummonOperation(false,s.spfilter,LOCATION_HAND|LOCATION_GRAVE,1,1,nil)
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[A DARK "Number" Xyz Monster that has this card attached to it as material gains this effect.
	● At the start of the Damage Step, if this card battles, inflict damage to your opponent equal to half of this card's DEF.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(s.xmatcon)
	e3:SetOperation(s.xmatop)
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
	if not c:IsRelateToBattle() then return false end
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.xmatop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() and c:IsFaceup() then
		local val=c:GetDefense()/2
		if val>0 then
			Duel.Hint(HINT_CARD,tp,c:GetOriginalCode())
			Duel.Damage(1-tp,val,REASON_EFFECT)
		end
	end
end