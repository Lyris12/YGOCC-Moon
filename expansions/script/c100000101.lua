--Aeonstrider Timekeeper
--Protettore del Tempo Marciaeoni
--Scripted by: XGlitchy30

local s,id,o=GetID()
Duel.LoadScript("glitchylib_helper.lua")
Duel.LoadScript("glitchylib_aeonstride.lua")
function s.initial_effect(c)
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	c:EnableReviveLimit()
	--[[If this card is Link Summoned: Place 1 Chronus Counter on it, then you can move the Turn Count forwards by 1 turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetFunctions(aux.LinkSummonedCond,nil,s.cttg,s.ctop)
	c:RegisterEffect(e1)
	--[[Once per Chain, if the Turn Count moves forwards (except during the Damage Step): You can activate 1 of this card's Link Arrows.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TURN_COUNT_MOVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetFunctions(s.lkcon,nil,s.lktg,s.lkop)
	c:RegisterEffect(e2)
	aux.RegisterTurnCountTriggerEffectFlag(c,e2)
	--[[If all of this card's Link Arrows are active, at the start of a Phase (Quick Effect): You can deactivate all of this card's Link Arrows;
	until the end of the turn, each time a player negates the activation, or effect, of a card or effect, they destroy 1 card they control or in their hand.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetRelevantTimings()
	e3:SetFunctions(s.negcon,s.negcost,s.negtg,s.negop)
	c:RegisterEffect(e3)
end
function s.mfilter(c)
	return c:IsLinkSetCard(ARCHE_AEONSTRIDE) and not c:IsLinkCode(id)
end

--E1
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local c=e:GetHandler()
	Duel.SetCardOperationInfo(c,CATEGORY_COUNTER)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsCanAddCounter(COUNTER_CHRONUS,1) then
		c:AddCounter(COUNTER_CHRONUS,1)
		if Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) and c:AskPlayer(tp,3) then
			Duel.BreakEffect()
			Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)
		end
	end
end

--E2
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	if aux.TurnCountMovedDueToTurnEnd then
		return r&REASON_RULE==0
	else
		return ev>0
	end
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanActivateLinkMarker() and not c:HasFlagEffect(id) end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() and c:IsCanActivateLinkMarker(nil,e,tp,REASON_EFFECT) then
		c:ActivateLinkMarker(nil,e,tp,REASON_EFFECT,true,c)
	end
end

--E3
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetLinkMarker()&LINK_MARKER_ALL==LINK_MARKER_ALL and not Duel.CheckPhaseActivity() and Duel.GetCurrentPhase()~=PHASE_BATTLE_STEP
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsCanDeactivateLinkMarker(LINK_MARKER_ALL,e,tp,REASON_COST)
	end
	c:DeactivateLinkMarker(LINK_MARKER_ALL,e,tp,REASON_COST,true,c)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id+100) end
	c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_CHAIN_NEGATED)
	ge1:SetOperation(s.checkop)
	ge1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(ge1,0)
	local ge2=ge1:Clone()
	Duel.RegisterEffect(ge2,1)
	local ge3=ge1:Clone()
	ge3:SetCode(EVENT_CHAIN_DISABLED)
	Duel.RegisterEffect(ge3,0)
	local ge4=ge3:Clone()
	Duel.RegisterEffect(ge4,1)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	if de and dp==tp then
		Duel.Hint(HINT_CARD,dp,id)
		local g=Duel.Select(HINTMSG_DESTROY,false,dp,aux.TRUE,dp,LOCATION_ONFIELD|LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end