--[[
Lich-Lord's Soul Prison
Prigione di Anime del Signore-Lich
Card Author: Walrus
Original Script by: ?
Updated by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_LICH_LORD_PHYLACTERY)
	--[[When your opponent activates a monster effect, while you control a "Lich-Lord" monster: Target 1 "Lich-Lord" monster you control;
	negate that effect, then, for the rest of this turn, that "Lich-Lord" monster gains the original effects of the monster whose effect was negated.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT()
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in the GY, except during the turn it was sent there: You can banish this card from your GY, then target 1 monster your opponent controls; it gains the following effect.
	● If a "Lich-Lord's Phylactery" is in your opponent's GY, this card's ATK becomes 0, also negate this card's other effects.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_LICH_LORD)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsDisabled() and Duel.IsChainDisablable(ev)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc) end
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToChain(ev) and tc:IsRelateToChain() and s.cfilter(tc) then
		local code=rc:GetOriginalCode()
		if tc:CopyEffect(code,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,1)>0 then
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
			tc:SetHint(CHINT_CARD,code)
		end
	end
end

--E2
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain() or tc:IsFacedown() then return end
	aux.GainEffectType(tc)
	tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(aux.ReversePhylacteryCondition)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(tc)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(aux.ReversePhylacteryCondition)
	e2:SetValue(0)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e2)
end