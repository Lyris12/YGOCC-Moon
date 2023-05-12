--Chevalier du Vaisseau
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	aux.EnableReviveLimitPendulumSummonable(c,LOCATION_EXTRA)
	--[[① During your Main Phase: You can add up to 2 "Vaisseau" Pendulum Monsters from your hand to your Extra Deck face-up,
	then apply these effects in sequence, depending on the number of cards added to the Extra Deck by this effect.
	● 1+: Draw 1 card
	● 2: Add 1 "Vaisseau" Ritual Spell from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOEXTRA|CATEGORY_DRAW|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.RegisterVaisseauPendulumEffectFlag(c,e1)
end
function s.filter(c)
	return c:IsMonster(TYPE_PENDULUM) and c:IsSetCard(ARCHE_VAISSEAU) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.Group(s.filter,tp,LOCATION_HAND,0,nil)
		return #g>0 and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.pcfilter(c)
	return c:IsSpell(TYPE_RITUAL) and c:IsSetCard(ARCHE_VAISSEAU) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.filter,tp,LOCATION_HAND,0,nil)
	if #g<=0 then return end
	local max=1
	if #g>=2 and Duel.GetDeckCount(tp)>1 and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK,0,1,nil) then
		max=2
	end
	local rg=Duel.Select(HINTMSG_TOEXTRA,false,tp,s.filter,tp,LOCATION_HAND,0,1,max,nil)
	if #rg>0 then
		Duel.ConfirmCards(1-tp,rg)
		if Duel.SendtoExtraP(rg,tp,REASON_EFFECT)>0 then
			local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
			if ct>=1 then
				if Duel.IsPlayerCanDraw(tp,1) then
					Duel.BreakEffect()
				end
				Duel.Draw(tp,1,REASON_EFFECT)
			end
			if ct==2 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local pg=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
				if #pg>0 then
					Duel.BreakEffect()
					Duel.Search(pg,tp)
				end
			end
		end
	end
end