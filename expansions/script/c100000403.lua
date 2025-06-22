--[[
Unknown HERO Bounty
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	--When a Special Summoned "Unknown HERO" monster you control destroys an opponent's monster by battle: Draw 3 cards, then if you have 7 or more cards in your hand, shuffle cards from your hand into the Deck until you have 5 cards left.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:HOPT()
	e1:SetFunctions(s.drawcon,nil,s.drawtg,s.drawop)
	c:RegisterEffect(e1)
	--During your End Phase, if this card is in your GY and a Special Summoned "Unknown HERO" monster you control destroyed an opponent's monster by battle previously this turn: You can banish this card from your GY; draw 2 cards, then discard 1 card.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_DRAW|CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_PHASE|PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SHOPT()
	e3:SetFunctions(s.drawcon2,aux.bfgcost,s.drawtg2,s.drawop2)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYING)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	local bc=c:GetBattleTarget()
	if bc then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_PHASE_END,0,1,bc:GetControler())
	end
end

--E1
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	return c:IsFaceup() and c:IsControler(tp) and c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO) and c:IsSpecialSummoned() and c:IsStatus(STATUS_OPPO_BATTLE)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,3)
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,3,REASON_EFFECT)==3 then
		local ct=Duel.GetHandCount(tp)
		if ct>=7 then
			local g=Duel.Select(HINTMSG_TODECK,false,tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,ct-5,ct-5,nil)
			if #g>0 then
				Duel.ShuffleHand(tp)
				Duel.BreakEffect()
				Duel.ShuffleIntoDeck(g)
			end
		end
	end
end

--E2
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO) and c:IsSpecialSummoned() and c:HasFlagEffectLabel(id,1-tp)
end
function s.drawcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.drawtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.drawop2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		Duel.ShuffleHand(p)
		Duel.BreakEffect()
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT|REASON_DISCARD)
	end
end