--[[
Manaseal Rune Weaving
Composizione di Rune Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()

function s.initial_effect(c)
	c:Activation(true,{TIMING_STANDBY_PHASE,0})
	--You can only control 1 "Manaseal Rune Weaving".
	c:SetUniqueOnField(1,0,id)
	--[[Once per turn, during your Draw Phase, before you draw: You can give up your normal draw this turn, and if you do, add 1 "Manaseal" card or "Rank-Up-Magic" Spell from your Deck or GY to your
	hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_SZONE)
	e1:OPT()
	e1:SetFunctions(
		aux.DrawPhaseCond(0),
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e1)
	--[[Each time a Spell Card or effect is activated, immediately after it resolves, draw 1 card, or if you have 7 or more cards in your hand, gain 500 LP instead.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.drawcon)
	e3:SetOperation(s.drawop)
	c:RegisterEffect(e3)
	--[[Once per turn, during your Standby Phase: Apply 1 of these effects.
	● You cannot activate Spell Cards or effects until the end of this turn, except "Remnant" or "Rank-Up-Magic" Spell Cards or effects
	● Place this card on the top of your Deck.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,1)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:OPT()
	e4:SetFunctions(
		aux.TurnPlayerCond(0),
		nil,
		s.applytg,
		s.applyop
	)
	c:RegisterEffect(e4)
end
--E1
function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsSetCard(ARCHE_MANASEAL) or (c:IsSetCard(ARCHE_RUM) and c:IsSpell()))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	aux.GiveUpNormalDraw(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end

--E2 and E3
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_FACEDOWN|RESET_CHAIN,0,1)
	end
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)~=0 and re:IsActiveType(TYPE_SPELL)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	if Duel.GetHandCount(tp)<7 then
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end

--E4
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,LOCATION_SZONE)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=true
	local b2=c:IsRelateToChain() and c:IsAbleToDeck()
	local opt=aux.Option(tp,id,2,b1,b2)
	if opt==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(id,4)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif opt==1 then
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end	
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL) and not re:GetHandler():IsSetCard(ARCHE_REMNANT,ARCHE_RUM)
end