--Dame du Vaisseau
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	aux.EnableReviveLimitPendulumSummonable(c,LOCATION_EXTRA)
	--[[During your Main Phase: You can destroy all cards in your Pendulum Zones, then apply these effects in sequence, depending on the number of cards destroyed by this effect.
	● 1+: Add 1 "Vaisseau" monster from your Deck to your Extra Deck face-up
	● 2: Add 1 face-up "Vaisseau" monster from your Extra Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_TOEXTRA|CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.RegisterVaisseauPendulumEffectFlag(c,e1)
	--[[If this card is Special Summoned: You can Set from your GY to your field, 1 "Vaisseau" Spell, or, if this card was Ritual Summoned, 1 "Vaisseau" Trap, instead.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetTarget(s.qetg)
	e2:SetOperation(s.qeop)
	c:RegisterEffect(e2)
end
function s.tefilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(ARCHE_VAISSEAU) and not c:IsForbidden()
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_VAISSEAU) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetPendulums(tp)
	if chk==0 then
		local ct=#g
		return ct>=1 and Duel.IsExistingMatchingCard(s.tefilter,tp,LOCATION_DECK,0,1,nil) and (ct<2 or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil))
	end
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetPendulums(tp)
	if #g>0 then
		local ct=Duel.Destroy(g,REASON_EFFECT)
		if ct>=1 then
			local rg=Duel.Select(HINTMSG_TOEXTRA,false,tp,s.tefilter,tp,LOCATION_DECK,0,1,1,nil)
			if #rg>0 then
				Duel.BreakEffect()
				Duel.SendtoExtraP(rg,tp,REASON_EFFECT)
			end
		end
		if ct==2 then
			local rg=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			if #rg>0 then
				Duel.BreakEffect()
				Duel.Search(rg,tp)
			end
		end
	end
end

function s.cfilter(c,bool)
	if not (c:IsSSetable() and c:IsSetCard(ARCHE_VAISSEAU)) then return false end
	return c:IsSpell() or (bool and c:IsTrap())
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler():IsRitualSummoned())
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bool = c:IsRelateToChain() and c:IsRitualSummoned()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.cfilter),tp,LOCATION_GRAVE,0,1,1,nil,bool)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end