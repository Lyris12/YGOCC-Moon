--[[
Number C203: Supreme Archangel of Verdanse
Numero C203: Supremo Arcangelo di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),6,3)
	aux.AddCodeList(c,CARD_NUMBER_203_ARCHANGEL_OF_VERDANSE)
	--[[If this card is Xyz Summoned: Attach 3 "Verdanse" Ritual Monsters from your hand and/or GY to this card as material, then,
	if this card was Xyz Summoned by the effect of a "Rank-Up-Magic" Spell that targeted "Number 203: Archangel of Verdanse",
	this card gains the original effects of "Number 203: Archangel of Verdanse".]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		s.atcon1,
		nil,
		aux.DummyCost,
		s.atop1
	)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCondition(s.atcon2)
	e1x:SetOperation(s.atop2)
	c:RegisterEffect(e1x)
	--[[Once per turn (Quick Effect): You can detach 1 material from this card; until the end of this turn, negate the effects of all face-up cards your opponent controls
	in the same column as a Special Summoned monster on the field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		nil,
		aux.DetachSelfCost(),
		aux.DummyCost,
		s.operation
	)
	c:RegisterEffect(e2)
	--[[While this card has "Number 203: Archangel of Verdanse" attached to it as material, negate the first activated monster effect, the first Spell Card or effect,
	and the first Trap Card or effect your opponent activates each turn, and if they were activated on the field, banish those cards, face-down.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon(TYPE_MONSTER))
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.negcon(TYPE_SPELL))
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.negcon(TYPE_TRAP))
	e5:SetOperation(s.negop)
	c:RegisterEffect(e5)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_RUM)
	if not s.valid_effects then
		s.valid_effects={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetCondition(s.discon)
		ge1:SetOperation(s.disop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAIN_SOLVED)
		ge2:SetCondition(s.disrescon)
		ge2:SetOperation(s.disresop)
		Duel.RegisterEffect(ge2,0)
	end
end
aux.xyz_number[id]=203
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(aux.FaceupFilter(Card.IsCode,CARD_NUMBER_203_ARCHANGEL_OF_VERDANSE),1,nil)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	s.valid_effects[re]=true
end
function s.disrescon(e,tp,eg,ep,ev,re,r,rp)
	return s.valid_effects[re]
end
function s.disresop(e,tp,eg,ep,ev,re,r,rp)
	s.valid_effects[re]=nil
end

--E1
function s.atcon1(e,tp,eg,ep,ev,re,r,rp)
	return aux.XyzSummonedCond(e) and (not re or not s.valid_effects[re])
end
function s.atcon2(e,tp,eg,ep,ev,re,r,rp)
	return aux.XyzSummonedCond(e) and re and s.valid_effects[re]
end
function s.atfilter(c,tp)
	return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and c:IsCanOverlay(tp)
end
function s.atop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsType(TYPE_XYZ) then
		local g=Duel.Select(HINTMSG_XMATERIAL,false,tp,aux.Necro(s.atfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,3,3,nil,tp)
		if #g==3 then
			Duel.HintSelection(g)
			Duel.Attach(g,c)
		end
	end
end
function s.atop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsType(TYPE_XYZ) then
		local g=Duel.Select(HINTMSG_XMATERIAL,false,tp,aux.Necro(s.atfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,3,3,nil,tp)
		if #g==3 then
			Duel.HintSelection(g)
			if Duel.Attach(g,c)==3 and re then
				local rc=re:GetHandler()
				if rc and re:IsActiveType(TYPE_SPELL) and aux.CheckArchetypeReasonEffect(s,re,ARCHE_RUM) and c:IsRelateToChain() and c:IsFaceup() then
					Duel.BreakEffect()
					c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
					c:CopyEffect(CARD_NUMBER_203_ARCHANGEL_OF_VERDANSE,RESET_EVENT|RESETS_STANDARD)
				end
			end
		end
	end
end

--E2
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(0,LOCATION_ONFIELD)
	e2:SetTarget(s.disable)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.disable(e,c)
	return (c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT or not c:IsLocation(LOCATION_MZONE))
		and c:GetColumnGroup():IsExists(Card.IsSpecialSummoned,1,nil)
end

--E3
function s.negcon(type)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,CARD_NUMBER_203_ARCHANGEL_OF_VERDANSE) and rp==1-tp and re:IsActiveType(type) and Duel.IsChainDisablable(ev)
			end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToChain(ev) and re:GetActivateLocation()&LOCATION_ONFIELD>0 then
		Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)
	end
end