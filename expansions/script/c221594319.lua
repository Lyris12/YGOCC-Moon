--[[
Voidictator Servant - Gate Attendant
Servitore dei Vuotodespoti - Addetta al Portale
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--This card cannot be used as a material for the Summon of a monster from the Extra Deck while it is on the field.
	aux.CannotBeEDMaterial(c,nil,LOCATION_ONFIELD,true)
	--[[You can send this card from your hand or field to the GY; add 1 "Voidictator Servant" Pendulum or Pandemonium Monster from your Deck or face-up Extra Deck to your hand,
	then, if this card was sent from the field to the GY to activate this effect, draw 1 card.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:HOPT()
	e1:SetLabel(0)
	e1:SetFunctions(nil,s.cost,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[If this card is banished because of a "Voidictator" card you own: You can shuffle this card into the Deck;
	add 1 "Voidictator Servant" Pendulum or Pandemonium Monster from your GY or banishment to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetFunctions(s.thcon,aux.ToDeckSelfCost,s.thtg,s.thop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end

--E1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	e:SetLabel(0)
	local loc=c:GetLocation()
	if Duel.SendtoGrave(c,REASON_COST)>0 then
		if c:IsLocation(LOCATION_GRAVE) and loc&LOCATION_ONFIELD>0 then
			e:SetLabel(1)
		end
	end
end
function s.filter(c,drawchk)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT) and c:IsType(TYPE_PENDULUM|TYPE_PANDEMONIUM) and c:IsAbleToHand()
		and (not drawchk or Duel.IsPlayerCanDraw(tp,2) or (Duel.IsPlayerCanDraw(tp,1) and c:IsLocation(LOCATION_EXTRA)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local costchk=e:IsCostChecked()
		if not costchk then
			e:SetLabel(0)
		end
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,costchk and e:GetHandler():IsOnField())
	end
	local lab=e:GetLabel()
	Duel.SetTargetParam(lab)
	if lab==1 then
		e:SetCategory(CATEGORIES_SEARCH|CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		e:SetCategory(CATEGORIES_SEARCH)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,false)
	if #g>0 and Duel.SearchAndCheck(g,tp) and Duel.GetTargetParam()==1 and e:IsActivated() then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GB,0,1,nil,false) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GB)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.filter),tp,LOCATION_GB,0,1,1,nil,false)
	if #g>0 then
		Duel.Search(g,tp)
	end
end