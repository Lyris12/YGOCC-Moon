--[[
Manaseal Word - Curse
Parola Manasigillo - Maledizione
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--If you control a "Manaseal" monster, you can activate this card from your hand.
	c:TrapCanBeActivatedFromHand(s.handactcon,aux.Stringid(id,5))
	--[[Activate 1 of these effects.
	● Negate the activation of the next Spell Card or effect your opponent activates, and if you do, place it on the bottom of the Deck. You cannot activate Spell Cards or effects during the turn you
	activate this effect, except "Rank-Up-Magic" or "Remnant" Spell Cards.
	● Banish 1 "Manaseal" monster from your hand or GY until the End Phase; negate the effects of 1 Spell your opponent controls.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(
		nil,
		aux.DummyCost,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	--[[If you control "Manaseal Rune Weaving" while this card is in your GY, apply the following effect.
	● Negate the effect of your opponent's first Spell Card or effect that resolves each turn, and if you do, or if it did not have an effect, banish that card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,4)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.negcon2)
	e2:SetOperation(s.negop2)
	c:RegisterEffect(e2)
	
end
function s.handactcon(e)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_MANASEAL),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.chainfilter(re)
	return not (re:IsActiveType(TYPE_SPELL) and not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(ARCHE_REMNANT,ARCHE_RUM)))
end

--E1
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_MANASEAL) and c:IsAbleToRemoveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(id,3)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_OATH|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return not s.chainfilter(re)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil) end
	local tc=Duel.Select(HINTMSG_REMOVE,false,tp,s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.BanishUntil(tc,e,tp,POS_FACEUP,PHASE_END,id,1,false,nil,REASON_COST,false,false)
	end
end
function s.disfilter(c,e)
	return aux.NegateAnyFilter(c) and c:IsSpell() and (not e or c:IsCanBeDisabledByEffect(e))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not e:IsCostChecked() or s.cost1(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=(not e:IsCostChecked() or s.cost2(e,tp,eg,ep,ev,re,r,rp,0)) and Duel.IsExists(false,s.disfilter,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_NEGATE|CATEGORY_TODECK)
		if e:IsCostChecked() then
			s.cost1(e,tp,eg,ep,ev,re,r,rp,1)
		end
		Duel.SetPossibleOperationInfo(0,CATEGORY_NEGATE,nil,1,1-tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,0)
	elseif opt==1 then
		e:SetCategory(CATEGORY_DISABLE)
		if e:IsCostChecked() then
			s.cost2(e,tp,eg,ep,ev,re,r,rp,1)
		end
		local g=Duel.Group(s.disfilter,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if opt==0 then
		local c=e:GetHandler()
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_CHAINING)
		e0:SetOperation(s.regop)
		Duel.RegisterEffect(e0,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(id,3)
		e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAIN_ACTIVATING)
		e3:OPT()
		e3:SetCondition(s.negcon)
		e3:SetOperation(s.negop)
		Duel.RegisterEffect(e3,tp)
	elseif opt==1 then
		local g=Duel.Select(HINTMSG_DISABLE,false,tp,s.disfilter,tp,0,LOCATION_ONFIELD,1,1,nil,e)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Negate(g:GetFirst(),e,nil,false,false,TYPE_SPELL)
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:IsActiveType(TYPE_SPELL) then
		Duel.RegisterFlagEffect(tp,id+100,RESET_CHAIN,0,1)
		e:Reset()
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL) and Duel.PlayerHasFlagEffect(tp,id+100)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.IsChainNegatable(ev) then
		Duel.Hint(HINT_CARD,tp,id)
		if Duel.NegateActivation(ev) and rc:IsRelateToChain(ev) then
			Duel.SendtoDeck(rc,nil,SEQ_DECKBOTTOM,REASON_EFFECT,tp,true)
		end
	end
	e:Reset()
end

--E2
function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING),tp,LOCATION_ONFIELD,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_SPELL)
end
function s.negop2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.IsChainDisablable(ev) then
		Duel.Hint(HINT_CARD,tp,id)
		if Duel.NegateEffect(ev) and rc:IsRelateToChain(ev) then
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		end
	end
end