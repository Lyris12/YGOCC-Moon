--[[
Curseflame Essence
Essenza Fiammaledetta
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--When this card is activated: You can add 1 "Curseflame" monster from your Deck or GY to your hand.
	local e0=c:Activation(true,nil,nil,nil,s.target,s.activate,true)
	e0:SetCategory(CATEGORIES_SEARCH|CATEGORY_GRAVE_ACTION)
	c:RegisterEffect(e0)
	--You can only control 1 "Curseflame Essence".
	c:SetUniqueOnField(1,0,id)
	--Once per turn: You can move up to 10 Curseflame Counters from anywhere on the field onto this card, and if you do, move any number of Curseflame Counters from this card onto other face-up cards on the field.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:OPT()
	e1:SetFunctions(nil,nil,s.cttg,s.ctop)
	c:RegisterEffect(e1)
	--Up to twice per turn: You can remove 3 Curseflame Counters from anywhere on the field; add 1 "Curseflame" card from your Deck or GY to your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT(2)
	e2:SetFunctions(
		nil,
		aux.RemoveCounterCost(COUNTER_CURSEFLAME,3,1,1),
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
end
--E0
function s.thfilter(c)
	return c:IsSetCard(ARCHE_CURSEFLAME) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.Search(sg,tp)
		end
	end
end

--E2
function s.ctfilter(c,tp)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_CURSEFLAME,1)
end
function s.ctcheck(c,g)
	return	function(i)
				return c:IsCanRemoveCounter(tp,COUNTER_CURSEFLAME,1,REASON_EFFECT) and g:CheckSubGroup(aux.DistributeCountersGroupCheck(COUNTER_CURSEFLAME),1,#g,i)
			end
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(Card.HasCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,COUNTER_CURSEFLAME)
	if chk==0 then
		return c:IsCanAddCounter(COUNTER_CURSEFLAME,1) and g:IsExists(Card.IsCanRemoveCounter,1,nil,tp,COUNTER_CURSEFLAME,1,REASON_EFFECT)
			and Duel.IsExists(false,s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,COUNTER_CURSEFLAME)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsCanAddCounter(COUNTER_CURSEFLAME,1) then return end
	local g=Duel.Group(Card.HasCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,COUNTER_CURSEFLAME)
	if #g==0 then return end
	local max=0
	for i=10,1,-1 do
		if g:CheckSubGroup(aux.PickCountersGroupCheck(COUNTER_CURSEFLAME),1,#g,i,nil,tp,REASON_EFFECT) then
			max=i
			break
		end
	end
	if max==0 then return end
	local n=Duel.AnnounceNumberMinMax(tp,1,max)
	local ct0=g:GetSum(Card.GetCounter,COUNTER_CURSEFLAME)
	if Duel.PickCounters(tp,COUNTER_CURSEFLAME,n,g,id,REASON_EFFECT)==0 then return end
	local ct=ct0-g:GetSum(Card.GetCounter,COUNTER_CURSEFLAME)
	if ct>0 and c:AddCounter(COUNTER_CURSEFLAME,ct) and c:IsRelateToChain() then
		local g2=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		max=c:GetCounter(COUNTER_CURSEFLAME)
		n=Duel.AnnounceNumberMinMax(tp,1,max,s.ctcheck(c,g2))
		if n==0 then return end
		if c:RemoveCounter(tp,COUNTER_CURSEFLAME,n,REASON_EFFECT) then
			local newct=max-c:GetCounter(COUNTER_CURSEFLAME)
			if newct>0 then
				Duel.DistributeCounters(tp,COUNTER_CURSEFLAME,newct,g2,id)
			end
		end
	end
end

--E3
function s.filter(c)
	return c:IsSetCard(ARCHE_CURSEFLAME) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end