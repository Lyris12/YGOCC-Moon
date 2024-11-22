--[[
Manaseal Prowess
Abilità Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[When a card or effect is activated while you control a face-up "Manaseal" card: Negate the actvation, and if you do, destroy it, then if you negated a Spell Card or effect this way, apply 1
	of the following effects.
	● Add 1 Level 5 or lower DARK monster from your Deck or GY to your hand.
	● Add 1 Normal Trap from your Deck or GY to your hand, and if you do, banish this card instead of sending it to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY|CATEGORIES_SEARCH|CATEGORY_GRAVE_ACTION|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT()
	e1:SetFunctions(
		s.condition,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, except during the turn it was sent there: You can target 1 other Spell/Trap in your GY; banish that target, and if you do, Set this card, but banish it when it
	leaves the field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetRelevantTimings()
	e2:SHOPT()
	e2:SetFunctions(
		aux.exccon,
		nil,
		s.settg,
		s.setop
	)
	c:RegisterEffect(e2)
end

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_MANASEAL)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return not re:IsActiveType(TYPE_SPELL)
			or Duel.IsExists(false,aux.Necro(s.thfilter1),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
			or Duel.IsExists(false,aux.Necro(s.thfilter1),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)>0 and re:IsActiveType(TYPE_SPELL) then
		local c=e:GetHandler()
		local b1=Duel.IsExists(false,aux.Necro(s.thfilter1),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
		local b2=Duel.IsExists(false,aux.Necro(s.thfilter2),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
		if not b1 and not b2 then return end
		local opt=aux.Option(tp,id,1,b1,b2)
		if opt==0 then
			local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter1),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.BreakEffect()
				Duel.Search(g)
			end
		elseif opt==1 then
			local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter2),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.BreakEffect()
				if Duel.SearchAndCheck(g) and c:IsRelateToChain() and c:IsAbleToRemove() and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
					Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
				end
			end
		end
	end
end
function s.thfilter1(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelBelow(5) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsNormalTrap() and c:IsAbleToHand()
end

--E2
function s.rmfilter(c)
	return c:IsST() and c:IsAbleToRemove()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.rmfilter(chkc) end
	if chk==0 then
		return c:IsSSetable() and Duel.IsExists(true,s.rmfilter,tp,LOCATION_GRAVE,0,1,c)
	end
	local g=Duel.Select(HINTMSG_REMOVE,true,tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsST() and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsSSetable() then
			Duel.SSetAndRedirect(tp,c,e)
		end
	end
end