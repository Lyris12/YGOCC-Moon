--[[
Automatyrant Lockdown
Automatiranno Lockdown
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--[[If you control an "Automatyrant" monster with 3 or more cards equipped to it, you can activate this card from your hand.]]
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(id,3)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)
	--[[If you control "Automatyrant Clockwork Dragon", or a Special Summoned "Automatyrant" monster with 2500 or more ATK:
	Activate as Chain Link 3 or higher; negate the activations of your opponent's cards and effects activated before this card in this Chain,
	and if you do, shuffle the negated cards on the field into the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is sent from your hand or Deck to the GY, or if this Set card you control is sent to the GY: You can banish this card from your GY,
	then target 1 "Automatyrant" monster you control with 3 or more cards equipped to it; until the Nth Standby Phase after this effect resolves,
	negate the effects of all Special Summoned monsters your opponent controls whose ATK is less than the ATK of that target. (N = The number of cards equipped to that target.)]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.discon,aux.bfgcost,s.distg,s.disop)
	c:RegisterEffect(e2)
end
--E0
function s.eqfilter0(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_AUTOMATYRANT) and c:GetEquipCount()>=3
end
function s.handcon(e)
	return Duel.IsExists(false,s.eqfilter0,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--E1
function s.cfilter(c)
	return c:IsFaceup()
		and (c:IsCode(CARD_AUTOMATYRANT_CLOCKWORK_DRAGON) or (c:IsLocation(LOCATION_MZONE) and c:IsSetCard(ARCHE_AUTOMATYRANT) and c:IsAttackAbove(2500) and c:IsSpecialSummoned()))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()<2 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then return false end
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and Duel.IsChainNegatable(i) then
			return true
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and Duel.IsChainNegatable(i) then
			local tc=te:GetHandler()
			ng:AddCard(tc)
			if tc:IsOnField() and tc:IsRelateToChain(i) and not tc:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(tp,tc) then
				dg:AddCard(tc)
			end
		end
	end
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,#ng,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,#dg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and Duel.NegateActivation(i) then
			local tc=te:GetHandler()
			if tc:IsRelateToChain() and tc:IsRelateToChain(i) and not tc:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(tp,tc) then
				tc:CancelToGrave()
				dg:AddCard(tc)
			end
		end
	end
	if #dg>0 then
		Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--E2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and (c:IsPreviousLocation(LOCATION_HAND|LOCATION_DECK) or (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)))
end
function s.eqfilter(c)
	return s.eqfilter0(c) and c:IsAttackAbove(1)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Select(HINTMSG_TARGET,true,tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and s.eqfilter(tc) then
		local c=e:GetHandler()
		local atk=tc:GetAttack()
		local rct=tc:GetEquipCount()
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_DISABLE)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetLabel(atk-1)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetTarget(s.disable)
		e1:SetReset(RESET_PHASE|PHASE_STANDBY,rct)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterHint(1-tp,id,RESET_PHASE|PHASE_STANDBY,rct,id,2,nil,e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE|PHASE_STANDBY)
		e2:OPT()
		e2:SetLabel(rct)
		e2:SetOperation(s.countop)
		e2:SetReset(RESET_PHASE|PHASE_STANDBY,rct)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.disable(e,c)
	return c:IsSpecialSummoned() and c:IsFaceup() and c:IsAttackBelow(e:GetLabel())
end
function s.countop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct>e:GetLabel() then
		e:Reset()
	end
end